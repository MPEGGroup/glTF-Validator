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

library gltf.extensions.mpeg_accessor_timed;

import 'package:gltf/gltf.dart';
import 'package:gltf/src/errors.dart';
import 'package:gltf/src/utils.dart';
import 'package:gltf/src/base/gltf_property.dart';
import 'package:gltf/src/ext/extensions.dart';

import 'package:meta/meta.dart';

const String IMMUTABLE = 'immutable';
const String SUGGESTED_UPDATE_RATE = 'suggestedUpdateRate';
const String BUFFER_VIEW = 'bufferView';

const List<String> MPEG_ACCESSOR_TIMED_PROPERTIES = [
  BUFFER_VIEW,
  IMMUTABLE,
  SUGGESTED_UPDATE_RATE
];
const String TIMESTAMP_DETLA = 'timestamp_delta';

const Extension mpegTimedAccessorExtension = Extension(
    'MPEG_accessor_timed', <Type, ExtensionDescriptor>{
  Accessor: ExtensionDescriptor(MPEGAccessorTimed.fromMap)
});

class MPEGAccessorTimed extends GltfProperty {
  final int _bufferViewIndex;
  final double m_updateRate;
  final bool m_immutable;

  BufferView _bufferView;

  MPEGAccessorTimed._(this._bufferViewIndex, this.m_updateRate,
      this.m_immutable, Map<String, Object> map, Object extras)
      : super(map, extras);

  BufferView get bufferView => _bufferView;

  static MPEGAccessorTimed fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_ACCESSOR_TIMED_PROPERTIES, context);
    }

    int bufferViewIndex;
    double updateRate;

    var immutable = true; 
    if (map.containsKey(IMMUTABLE)){
      immutable = getBool(map, IMMUTABLE, context);
    }
    // bufferViewIndex is optional, 
    // however immutable=true implies that it should exist.
    bufferViewIndex = getIndex(map, BUFFER_VIEW, context, req: !immutable);
    updateRate = getFloat(map, SUGGESTED_UPDATE_RATE, context, def: 25.0);
    
    return MPEGAccessorTimed._(
        bufferViewIndex,
        updateRate,
        immutable,
        getExtensions(map, MPEGAccessorTimed, context),
        getExtras(map, context)); }

  @override
  void link(Gltf gltf, Context context) {

    final baseAccessorIndex = context.path[1];
    final baseAccessor = gltf.accessors[int.parse(baseAccessorIndex)];

    _bufferView = gltf.bufferViews[_bufferViewIndex];
    
    if (context.validate){

      if(_bufferViewIndex != -1) {
        if (_bufferView == null) {
          context.addIssue(LinkError.unresolvedReference,
              name: BUFFER_VIEW, args: [_bufferViewIndex]);
        } else {
          _bufferView.markAsUsed();
        }
      }

      if ((bufferView != null) && (baseAccessor.bufferView != null)){
        if (bufferView.buffer != baseAccessor.bufferView.buffer){
          context.addIssue(LinkError.mpegAccessorTimedBufferReferenceMissmatch, 
              args: [baseAccessorIndex]);
        }
      }

      if ((bufferView == null) && (baseAccessor.bufferView == null)){
          context.addIssue(LinkError.mpegAccessorTimedMissingBufferView, 
              args: [baseAccessorIndex]);
      }

    }
    
  }
}
