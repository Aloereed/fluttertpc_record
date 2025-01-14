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
import { RecordConfig } from './RecordConfig';

export interface IRecorder {

  start(config: RecordConfig): void;

  stop: (callback?: (path: string) => void) => void;

  /**
   * Stops the recording and delete file.
   */
  cancel(): void;

  /**
   * Pauses the recording if currently running.
   */
  pause(): void;

  /**
   * Resumes the recording if currently paused.
   */
  resume(): void;

  /**
   * Gets the state the of recording
   *
   * @return True if recording. False otherwise.
   */
  isRecording: Boolean;

  /**
   * Gets the state the of recording
   *
   * @return True if paused. False otherwise.
   */
  isPaused: Boolean;

  /**
   * Gets the amplitude
   *
   * @return List with current and max amplitude values
   */
  getAmplitude(): Array<number>;

  dispose(): void;
}