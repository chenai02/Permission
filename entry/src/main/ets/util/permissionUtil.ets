import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';

const PERMISSION_UTIL = 'PermissionUtil';

export async function checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let atManager = abilityAccessCtrl.createAtManager();
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

  // 获取应用程序的accessTokenID
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error(PERMISSION_UTIL, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
  }

  // 校验应用是否被授予权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error(PERMISSION_UTIL, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
  }
  // 获取当前权限的授权结果，grantStatus为0表示已授权，-1表示未授权
  return grantStatus;
}

export async function requestPermission(context: Context, permissions: Permissions[]):Promise<number[]> {
  let notGranted: Permissions[] = [];
  let atManager = abilityAccessCtrl.createAtManager();

  let authResults: number[] = [];

  for (const permission of permissions.entries()) {
    console.debug(PERMISSION_UTIL, "number: " + permission[0], " permission: " + permission[1])
    let grantStatus: abilityAccessCtrl.GrantStatus = await checkAccessToken(permission[1])
    if (grantStatus === 0) {
      console.debug(PERMISSION_UTIL, " permission " + permission[1] + " has granted")
      authResults.push(0)
      continue
    }
    notGranted.push(permission[1])
  }
  if (notGranted.length === 0) {
    return authResults
  }

  try {
    let permissionRequestResult = await atManager.requestPermissionsFromUser(context, notGranted)
    authResults.push(...permissionRequestResult.authResults)
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error(PERMISSION_UTIL, `Failed to request permissions. Code is ${err.code}, message is ${err.message}`);
    if (authResults.length < permissions.length){
      authResults.push(...new Array(permissions.length - authResults.length).fill(-1))
    }
  }
  console.debug(PERMISSION_UTIL, " all authResults: " + JSON.stringify(authResults))
  return authResults
}