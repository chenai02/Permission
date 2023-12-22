import router from '@ohos.router'
import abilityAccessCtrl, {  Permissions } from '@ohos.abilityAccessCtrl'
import common from '@ohos.app.ability.common';
import { checkAccessToken, requestPermission } from '../util/permissionUtil'

const permissionTo: Map<string, string> = new Map([
  [
    "calendar", "日历"
  ],
  [
    "location", "位置"
  ],
  [
    "hybrid", "混合"
  ],
  [
    "microphone", "麦克风"
  ],
  [
    "contact", "通讯录"
  ]
])
const permissionGroup: Map<string, Array<string>> = new Map([
  [
    "calendar", ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR']
  ],
  [
    "location", ['ohos.permission.APPROXIMATELY_LOCATION']
  ],
  [
    "microphone", ['ohos.permission.MICROPHONE']
  ],
  [
    "contact", ['ohos.permission.READ_CONTACTS', 'ohos.permission.WRITE_CONTACTS']
  ],
  [
    "hybrid", ['ohos.permission.READ_CALENDAR', 'ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.MICROPHONE', 'ohos.permission.WRITE_CONTACTS']
  ]
])


@Entry
@Component
struct PermissionPage {
  @State granted: string[] = [];
  @State notGranted: string[] = [];
  private allPermission: Map<string, Array<string>> = new Map();
  private ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async checkToken(data: Array<string>, group: string) {
    // 校验应用是否被授予权限
    let isGranted: boolean = true
    for (const permission of data) {
      let isAccess = await checkAccessToken(permission as Permissions)
      if (isAccess == abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        isGranted = false
        break
      }
    }
    if (isGranted) {
      if (this.granted.includes(group)) {
        return
      }
      this.granted.push(group)
      if (this.notGranted.indexOf(group) !== -1) {
        this.notGranted.splice(this.notGranted.indexOf(group), 1)
      }

      return
    }
    if (this.notGranted.includes(group)) {
      return
    }
    this.notGranted.push(group)
    if (this.granted.indexOf(group) !== -1) {
      this.granted.splice(this.granted.indexOf(group), 1)
    }
  }

  aboutToAppear() {
    this.allPermission = permissionGroup
    this.allPermission.forEach((data, group) => {
      this.checkToken(data, group)
    })

  }

  onPageShow() {
    this.allPermission.forEach((data, group) => {
      this.checkToken(data, group)
    })
  }

  build() {
    Navigation() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.search'))
              .height(21)
              .width(21)
              .margin({ right: 10 })
              .onClick(() => {
                router.back();
              })
            Text("权限")
              .fontSize(20)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .padding({ left: 7,
          right: 7 })
        .margin({ top: 40 })
        .height(47)
        .justifyContent(FlexAlign.SpaceAround)

        Row() {
          Text("已授权")
            .fontSize(14)
            .width('30%')
            .fontWeight(400)
            .fontColor("#989A9C")
        }
        .width("90%")
        .margin({
          top: 20,
          bottom: 15
        })

        List({ space: 12 }) {
          ForEach(this.granted, (item: string) => {
            ListItem() {
              Column() {
                MainItem({
                  title: item,
                  tag: ">",
                  context: this.ctx
                })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding(4)

            }
          }, (item: string) => JSON.stringify(item))
        }

        Row() {
          Text("未授权")
            .fontSize(14)
            .width('30%')
            .fontWeight(400)
            .fontColor("#989A9C")
        }
        .width("90%")
        .margin({
          top: 20,
          bottom: 15
        })

        List({ space: 12 }) {
          ForEach(this.notGranted, (item: string) => {
            ListItem() {
              Column() {
                MainItem({
                  title: item,
                  tag: ">",
                  context: this.ctx
                })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding(4)

            }
          }, (item: string) => JSON.stringify(item))
        }

        Blank()
        Text('去设置')
          .fontColor('#ff052280')
          .fontSize(14)
          .lineHeight(19)
          .margin({ top: 20, bottom: 140 })
          .onClick(() => {
            // openPermissionsInSystemSettings()
          })
      }
      .width('95%')
      .height('100%')
    }
    .padding({ left: 12, right: 12 })
    .mode(NavigationMode.Stack)
    .width('106%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .titleMode(NavigationTitleMode.Full)
    .hideTitleBar(true)
  }
}

@Component
export struct MainItem {
  private title?: string
  private tag?: string | Resource
  private context?: Context

  build() {
    Row() {
      Text(permissionTo.get(this.title as string))
        .fontSize(16)
        .lineHeight(22)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .align(Alignment.Start)
        .margin({ left: 16 })
      Blank()

      Text(this.tag)
        .fontSize(14)
        .lineHeight(19)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .onClick(()=>{
          //测试requestPermission接口catch错误场景
          // let context: Context =  (this.context as Context).createModuleContext("entry")
          // requestPermission(context,  permissionGroup.get(this.title) as Permissions[])
          requestPermission(this.context, permissionGroup.get(this.title as string) as Permissions[])

        })


    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(56)
    .borderRadius(20)
    .padding({ left: 8, right: 8 })

  }
}

