import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { initNotificationContext,
  requestCalendarPermission,
  requestNotificationPermission, todayDueTimeNotify } from '../utils/NotificationUtils';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(){
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }
  //=============================================================================
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    //初始化上下文
    initNotificationContext(this.context);
    //申请普通通知权限
    await requestNotificationPermission();
    //申请日历权限
    await requestCalendarPermission()
  }

  async onWindowStageDestroy(){
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    // //检查今日到期任务
    // await todayDueTimeNotify()
  }

  onForeground(){
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');

  }

  async onBackground(){
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    // //检查今日到期任务
    // await todayDueTimeNotify()
  }
}
