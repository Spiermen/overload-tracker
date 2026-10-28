/* DadStrong native bridge — no-ops on web/PWA; active inside Capacitor iOS. */
(function (global) {
  'use strict';
  const KEY = 'overload.native';
  const FREE_FRIENDS = 2;
  const RC_API_KEY = 'appl_REPLACE_WITH_REVENUECAT_IOS_KEY'; // set before TestFlight

  function cap() { return global.Capacitor || null; }
  function isNative() {
    try { return !!(cap() && cap().isNativePlatform && cap().isNativePlatform()); } catch (e) { return false; }
  }
  function plugin(name) {
    try { return cap() && cap().Plugins && cap().Plugins[name]; } catch (e) { return null; }
  }
  function load() {
    try { return JSON.parse(localStorage.getItem(KEY) || '{}') || {}; } catch (e) { return {}; }
  }
  function save(p) {
    try { localStorage.setItem(KEY, JSON.stringify({ ...load(), ...p })); } catch (e) { }
  }

  const Native = {
    isNative,
    get prefs() { return load(); },
    setPref(p) { save(p); },

    async init() {
      if (!isNative()) return;
      // Skip SW in native shell (Capacitor serves bundled assets)
      try { if ('serviceWorker' in navigator) { const regs = await navigator.serviceWorker.getRegistrations(); for (const r of regs) await r.unregister(); } } catch (e) { }
      try {
        const SB = plugin('StatusBar');
        if (SB) { await SB.setStyle({ style: 'DARK' }); await SB.setBackgroundColor({ color: '#0a0a0a' }); }
      } catch (e) { }
      await Native.initPurchases();
      await Native.refreshPro();
      if (load().healthOn) {
        try { await Native.requestHealth(); } catch (e) { }
      }
      if (load().remindOn) {
        try { await Native.scheduleReminders(load().remindHour ?? 18, load().remindDays || [1, 3, 5]); } catch (e) { }
      }
    },

    async initPurchases() {
      const P = plugin('Purchases');
      if (!P || !RC_API_KEY || RC_API_KEY.includes('REPLACE')) return;
      try {
        await P.configure({ apiKey: RC_API_KEY, appUserID: null });
      } catch (e) { console.warn('Purchases configure', e); }
    },

    async refreshPro() {
      const P = plugin('Purchases');
      if (!P || RC_API_KEY.includes('REPLACE')) {
        // Dev / web: honor local unlock flag for UI testing
        return !!load().pro;
      }
      try {
        const info = await P.getCustomerInfo();
        const active = info && info.customerInfo && info.customerInfo.entitlements && info.customerInfo.entitlements.active;
        const pro = !!(active && (active.pro || active.Pro || active.dadstrong_pro));
        save({ pro });
        return pro;
      } catch (e) { return !!load().pro; }
    },

    isPro() { return !!load().pro; },

    canAddFriend(count) {
      if (Native.isPro()) return true;
      return count < FREE_FRIENDS;
    },
    freeFriendLimit: FREE_FRIENDS,

    async purchasePro() {
      const P = plugin('Purchases');
      if (!isNative() || !P || RC_API_KEY.includes('REPLACE')) {
        // Scaffold: simulate unlock on web / until RC keys exist
        save({ pro: true });
        return { ok: true, simulated: true };
      }
      try {
        const offerings = await P.getOfferings();
        const current = offerings && offerings.current;
        const pkg = current && (current.availablePackages || [])[0];
        if (!pkg) return { ok: false, reason: 'no_offering' };
        await P.purchasePackage({ aPackage: pkg });
        await Native.refreshPro();
        return { ok: !!load().pro };
      } catch (e) {
        if (String(e && e.message || e).toLowerCase().includes('cancel')) return { ok: false, reason: 'cancelled' };
        return { ok: false, reason: String(e && e.message || e) };
      }
    },

    async restorePro() {
      const P = plugin('Purchases');
      if (!P || RC_API_KEY.includes('REPLACE')) return !!load().pro;
      try { await P.restorePurchases(); return await Native.refreshPro(); } catch (e) { return false; }
    },

    async requestHealth() {
      const B = plugin('DadStrongBridge');
      if (!B) return false;
      const r = await B.requestHealthAuth();
      save({ healthOn: !!(r && r.granted) });
      return !!(r && r.granted);
    },

    async saveWorkoutToHealth(w) {
      if (!isNative() || !load().healthOn) return;
      const B = plugin('DadStrongBridge');
      if (!B || !w) return;
      try {
        await B.saveWorkout({ start: w.start, end: w.end || Date.now(), name: w.name || 'Workout' });
      } catch (e) { console.warn('HealthKit save', e); }
    },

    async pushWidget(stats) {
      if (!isNative()) return;
      const B = plugin('DadStrongBridge');
      if (!B || !stats) return;
      try {
        await B.updateWidgetData({
          streak: stats.streak || 0,
          lastName: stats.lastName || '',
          lastDate: stats.lastDate || 0,
          setsThisWeek: stats.setsThisWeek || 0
        });
      } catch (e) { }
    },

    async requestNotifPermission() {
      const LN = plugin('LocalNotifications');
      if (!LN) return false;
      const perm = await LN.requestPermissions();
      return (perm && (perm.display === 'granted' || perm.display === 'prompt')) || false;
    },

    async scheduleReminders(hour, days) {
      const LN = plugin('LocalNotifications');
      if (!LN) return false;
      await Native.requestNotifPermission();
      // cancel prior DadStrong reminders (ids 7001+)
      try {
        const pending = await LN.getPending();
        const ids = (pending && pending.notifications || []).map(n => n.id).filter(id => id >= 7001 && id <= 7010);
        if (ids.length) await LN.cancel({ notifications: ids.map(id => ({ id })) });
      } catch (e) { }
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const list = (days || [1, 3, 5]).slice(0, 7).map((dow, i) => ({
        id: 7001 + i,
        title: 'DadStrong',
        body: 'Time to lift. Even 30 minutes counts — show up for you and the kids.',
        schedule: { on: { weekday: dow + 1, hour: hour | 0, minute: 0 }, allowWhileIdle: true, repeats: true },
        sound: 'default',
        extra: { kind: 'workout_reminder', day: dayNames[dow] }
      }));
      if (!list.length) return false;
      await LN.schedule({ notifications: list });
      save({ remindOn: true, remindHour: hour | 0, remindDays: days || [1, 3, 5] });
      return true;
    },

    async clearReminders() {
      const LN = plugin('LocalNotifications');
      if (!LN) return;
      try {
        const pending = await LN.getPending();
        const ids = (pending && pending.notifications || []).map(n => n.id).filter(id => id >= 7001 && id <= 7010);
        if (ids.length) await LN.cancel({ notifications: ids.map(id => ({ id })) });
      } catch (e) { }
      save({ remindOn: false });
    }
  };

  global.DadStrongNative = Native;
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => Native.init());
  else Native.init();
})(window);
