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

library gltf.extensions.mpeg_buffer_circular;

import 'package:gltf/gltf.dart';
import 'package:gltf/src/utils.dart';
import 'package:gltf/src/base/gltf_property.dart';
import 'package:gltf/src/ext/extensions.dart';
import 'package:gltf/src/ext/MPEG_media/mpeg_media.dart';

const String COUNT = 'count';
const String MEDIA = 'media';
const String TRACKS = 'tracks';

const List<String> MPEG_BUFFER_CIRCULAR_PROPERTIES = [
  COUNT,
  MEDIA,
  TRACKS
];

const Extension mpegBufferCircularExtension = Extension(
    'MPEG_buffer_circular', <Type, ExtensionDescriptor>{
  Buffer: ExtensionDescriptor(MPEGBufferCircular.fromMap)
});

class MPEGBufferCircular extends GltfProperty {
  final int count;
  final int media;
  final List<int> tracks;

  MPEGBufferCircular._(this.count, this.media, this.tracks,
      Map<String, Object> map, Object extras)
      : super(map, extras);

  static MPEGBufferCircular fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_BUFFER_CIRCULAR_PROPERTIES, context);
    }
    final count = getUint(map, COUNT, context, min: 2);    
    final media = getIndex(map, MEDIA, context, req: true);
    final trackList = getIndicesList(map, TRACKS, context);

    return MPEGBufferCircular._(
        count,
        media,
        trackList,
        getExtensions(map, MPEGBufferCircular, context),
        getExtras(map, context));
  }

  @override
  void link(Gltf gltf, Context context) {
    if (context.validate) {
        // Check media reference
        if (media != -1) {
          final _mediaObj = gltf.extensions['MPEG_media'] as MPEGMediaObject;
          MPEGMedia _media;
          if (_mediaObj != null) {
            _media = _mediaObj.getMpegMedia(media);
          } 
          if (_media == null) {
            context.addIssue(LinkError.unresolvedReference,
                name: MEDIA, args: [media]);
          } else {
            _media.markAsUsed();
          }
        }
    }
  }
}