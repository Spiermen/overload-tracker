import { registerPlugin } from '@capacitor/core';
const DadStrongBridge = registerPlugin('DadStrongBridge', {
  web: () => ({
    isNative: async () => ({ native: false, platform: 'web' }),
    requestHealthAuth: async () => ({ granted: false }),
    saveWorkout: async () => ({ saved: false }),
    updateWidgetData: async () => ({ ok: false })
  })
});
export { DadStrongBridge };
