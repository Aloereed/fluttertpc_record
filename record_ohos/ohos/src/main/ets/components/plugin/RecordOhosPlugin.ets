/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { FlutterPlugin, FlutterPluginBinding, MethodChannel, } from '@ohos/flutter_ohos';
import { MethodCallHandlerImpl } from './MethodCallHandlerImpl';

export default class RecordOhosPlugin implements FlutterPlugin {
  private readonly TAG: string = 'RecordOhosPlugin';
  private readonly MESSAGES_CHANNEL = 'com.llfbandit.record/messages';
  private channel: MethodChannel | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "RecordOhosPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), this.MESSAGES_CHANNEL);
    let methodCallHandlerImpl: MethodCallHandlerImpl = new MethodCallHandlerImpl(binding.getBinaryMessenger());
    this.channel.setMethodCallHandler(methodCallHandlerImpl);
    this.checkPermission();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
      this.channel = null;
    }
  }

  async checkPermission(): Promise<void> {
    const permissions: Array<Permissions> = ['ohos.permission.MICROPHONE'];
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus;
    let tokenId: number;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
      try {
        grantStatus = await atManager.checkAccessToken(tokenId, permissions[0]);
        if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          this.requestNecessaryPermissions(permissions);
        }
      } catch (err) {
        console.error(this.TAG + ` checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
      }
    } catch (err) {
      console.error(this.TAG + ` getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
    }

  }

  /**
   * 申请录音授权
   * @param permissions
   */
  requestNecessaryPermissions(permissions: Array<Permissions>): void {
    let context = getContext(this);
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        } else {
          return;
        }
      }
    }).catch((err: Error) => {
      console.error(this.TAG + ` requestPermissionsFromUser failed, code is ${err.name}, message is ${err.message}`);
    });
  }
}