export interface DadStrongBridgePlugin {
  isNative(): Promise<{ native: boolean; platform: string }>;
  requestHealthAuth(): Promise<{ granted: boolean }>;
  saveWorkout(opts: { start: number; end: number; name?: string }): Promise<{ saved: boolean; id?: string }>;
  updateWidgetData(opts: { streak: number; lastName: string; lastDate: number; setsThisWeek: number }): Promise<{ ok: boolean }>;
}
export declare const DadStrongBridge: DadStrongBridgePlugin;
