import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { initNotificationContext,
  requestCalendarPermission,
  requestNotificationPermission, todayDueTimeNotify } from '../utils/NotificationUtils';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private mainWindowStage: window.WindowStage | null = null

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // 黑金主题固定深色，避免状态栏默认黑字叠在黑底上看不清
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
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
    this.mainWindowStage = windowStage
    //在加载内容之前设置全屏
    await this.setImmersiveWindow(windowStage)

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

  /** 全屏：透明系统栏 + 浅色图标（时间、电量等） */
  private async setImmersiveWindow(windowStage: window.WindowStage): Promise<void> {
    try {
      //拿到主窗口级对象
      const mainWindow = await windowStage.getMainWindow();
      //窗口布局延伸到状态栏、导航栏
      await mainWindow.setWindowLayoutFullScreen(true);
      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',//状态栏背景：全透明
        navigationBarColor: '#00000000',//底部导航栏：全透明
        statusBarContentColor: '#FFFFFF',//状态栏文字/图标：白色
        navigationBarContentColor: '#FFFFFF',//导航栏：白色
        isStatusBarLightIcon: true,//导航栏和状态栏用浅色避免黑金色背景下看不清
        isNavigationBarLightIcon: true
      });
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set immersive window. Cause: %{public}s', JSON.stringify(err));
    }
  }

  async onWindowStageDestroy(){
    this.mainWindowStage = null
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    // //检查今日到期任务
    // await todayDueTimeNotify()
  }

  onForeground(){
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    // 从后台回到前台时重新设置，防止系统栏样式被重置
    if (this.mainWindowStage) {
      this.setImmersiveWindow(this.mainWindowStage);
    }
  }

  async onBackground(){
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    // //检查今日到期任务
    // await todayDueTimeNotify()
  }
}
