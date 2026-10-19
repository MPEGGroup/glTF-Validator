/**
 * The copyright in this software is being made available under the BSD License, included below.
 * This software may be subject to other third party and contributor rights, including patent
 * rights, and no such rights are granted under this license.
 *
 * Copyright (c) 2010-2021, ISO/IEC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *  * Neither the name of the ISO/IEC nor the names of its contributors may be used to endorse or
 *    promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
library gltf.extensions.mpeg_texture_video;

import 'package:gltf/src/base/gltf_property.dart';
import 'package:gltf/src/ext/extensions.dart';

const String VIDEO_TEXTURE_WIDTH = 'width';
const String VIDEO_TEXTURE_HEIGHT = 'height';
const String TIMED_ACCESSOR = 'accessor';
const String TEXTURE_FORMAT = 'format';

const List<String> MPEG_TEXTURE_VIDEO_PROPERTIES = [
  VIDEO_TEXTURE_HEIGHT,
  VIDEO_TEXTURE_WIDTH,
  TIMED_ACCESSOR,
  TEXTURE_FORMAT
];

const String RED = 'RED';
const String GREEN = 'GREEN';
const String BLUE = 'BLUE';
const String RG = 'RG';
const String RGB = 'RGB';
const String BGR = 'BGR';
const String RGBA = 'RGBA';
const String BGRA = 'BGRA';
const String DEPTH = 'DEPTH_COMPONENT';

const List<String> MPEG_TEXTURE_VIDEO_FORMATS = [
  RED,
  GREEN,
  BLUE,
  RG,
  RGB,
  RGBA,
  BGR,
  BGRA,
  DEPTH
];

const Extension mpegTextureVideoExtension = Extension(
    'MPEG_texture_video', <Type, ExtensionDescriptor>{
  Texture: ExtensionDescriptor(MPEGTextureVideo.fromMap)
});

class MPEGTextureVideo extends GltfProperty {
  final int videoTextureHeight;
  final int videoTextureWidth;
  final int accessorIndex;
  final String textureFormat;
  MPEGTextureVideo._(
      this.videoTextureHeight,
      this.videoTextureWidth,
      this.accessorIndex,
      this.textureFormat,
      Map<String, Object> map,
      Object extras)
      : super(map, extras);

  static MPEGTextureVideo fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_TEXTURE_VIDEO_PROPERTIES, context);
    }

    final height =
        getUint(map, VIDEO_TEXTURE_HEIGHT, context, min: 1, req: true);
    final width = getUint(map, VIDEO_TEXTURE_WIDTH, context, min: 1, req: true);
    final timedAccessorIndex =
        getIndex(map, TIMED_ACCESSOR, context, req: true);
    final format = getString(map, TEXTURE_FORMAT, context,
        def: RGB, list: MPEG_TEXTURE_VIDEO_FORMATS);
    return MPEGTextureVideo._(height, width, timedAccessorIndex, format,
        getExtensions(map, MPEGTextureVideo, context), getExtras(map, context));
  }

  Accessor _accessor;
  Accessor get accessor => _accessor;

  @override
  void link(Gltf gltf, Context context) {
    _accessor = gltf.accessors[accessorIndex];
    if (context.validate && accessorIndex != -1) {
      if (_accessor == null) {
        context.addIssue(LinkError.unresolvedReference,
            name: TIMED_ACCESSOR, args: [accessorIndex]);
      } else {
        _accessor.markAsUsed();
      }
    }
  }
}
