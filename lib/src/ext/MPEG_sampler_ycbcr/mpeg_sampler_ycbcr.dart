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

library gltf.extensions.mpeg_sampler_ycbcr;

import 'package:gltf/gltf.dart';
import 'package:gltf/src/base/gltf_property.dart';

const String YCBCR_MODEL = "ycbcrModel";
const String YCBCR_RANGE = "ycbcrRange";
const String CHROMA_FILTER = "chromaFilter";
const String COMPONENTS = "components";
const String XCHROMA_OFFSET = "xChromaOffset";
const String YCHROMA_OFFSET = "yChromaOffset";

const List<String> MPEG_SAMPLER_YCBCR_PROPERTIES = <String>[
  YCBCR_MODEL,
  YCBCR_RANGE,
  CHROMA_FILTER,
  COMPONENTS,
  XCHROMA_OFFSET,
  YCHROMA_OFFSET
];

enum YCbCrModel {
  RGB_IDENTITY, // 0
  YCBCR_IDENTITY, // 1
  YCBCR_709, // 2
  YCBCR_601, // 3
  YCBCR_2020 // 4
}

enum YCbCrRange {
  ITU_FULL, // 0
  ITU_NARROW // 1
}

enum ChromaLocation {
  COSITED_EVEN, // 0
  MIDPOINT // 1
}

enum Filter {
  NEAREST, // 0
  LINEAR, // 1
  CUBIC // 2
}

enum ComponentSwizzle {
  COMPOMENT_SWIZZLE_IDENTITY, // 0
  COMPONENT_SWIZZLE_ZERO, // 1
  COMPONENT_SWIZZLE_ONE, // 2
  COMPONENT_SWIZZLE_R, // 3
  COMPONENT_SWIZZLE_G, // 4
  COMPONENT_SWIZZLE_B, // 5
  COMPONENT_SWIZZLE_A // 6
}

class Components {
  final ComponentSwizzle r;
  final ComponentSwizzle g;
  final ComponentSwizzle b;
  final ComponentSwizzle a;

  Components._(this.r, this.g, this.b, this.a);

  static Components fromMap(Map<String, Object> map, Context context) {
    final components = SafeList<ComponentSwizzle>(4, 'components');
    for (var i = 0; i < 4; i++) {
      components[i] = ComponentSwizzle.COMPOMENT_SWIZZLE_IDENTITY;
    }
    if (map.containsKey(COMPONENTS)) {
      final values = map[COMPONENTS];
      if (values is! List<Object>) {
        context.addIssue(SchemaError.typeMismatch,
            name: COMPONENTS, args: [values, 'array']);
      } else if ((values as List<Object>).length != 4) {
        context.addIssue(SchemaError.arrayLengthNotInList,
            name: COMPONENTS,
            args: [
              (values as List<Object>).length,
              [4]
            ]);
      } else {
        final componentValues = values as List<Object>;
        context.path.add(COMPONENTS);
        for (var i = 0; i < 4; i++) {
          final name = i.toString();
          final index = getUint(
              <String, Object>{name: componentValues[i]}, name, context,
              max: ComponentSwizzle.values.length - 1, req: true);
          if (index >= 0) {
            components[i] = ComponentSwizzle.values[index];
          }
        }
        context.path.removeLast();
      }
    }
    return Components._(
        components[0], components[1], components[2], components[3]);
  }
}

const Extension mpegSamplerYCbCrExtension = Extension(
    'MPEG_sampler_YCbCr', <Type, ExtensionDescriptor>{
  Sampler: ExtensionDescriptor(MPEGSamplerYCbCr.fromMap)
});

class MPEGSamplerYCbCr extends GltfProperty {
  final YCbCrModel ycbcrmodel;
  final YCbCrRange ycbcrrange;
  final Filter filter;
  final Components components;
  final ChromaLocation xChromaOffset;
  final ChromaLocation yChromaOffset;

  MPEGSamplerYCbCr._(
      this.ycbcrmodel,
      this.ycbcrrange,
      this.filter,
      this.components,
      this.xChromaOffset,
      this.yChromaOffset,
      Map<String, Object> extensions,
      Object extras)
      : super(extensions, extras);

  static MPEGSamplerYCbCr fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_SAMPLER_YCBCR_PROPERTIES, context);
    }
    final ycbcrModel = _enumValue(map, YCBCR_MODEL, context, YCbCrModel.values);
    final ycbcrRange = _enumValue(map, YCBCR_RANGE, context, YCbCrRange.values);
    final filter = _enumValue(map, CHROMA_FILTER, context, Filter.values);
    final components = Components.fromMap(map, context);
    final xchromaOffset =
        _enumValue(map, XCHROMA_OFFSET, context, ChromaLocation.values);
    final ychromaOffset =
        _enumValue(map, YCHROMA_OFFSET, context, ChromaLocation.values);

    return MPEGSamplerYCbCr._(
        ycbcrModel,
        ycbcrRange,
        filter,
        components,
        xchromaOffset,
        ychromaOffset,
        getExtensions(map, MPEGSamplerYCbCr, context),
        getExtras(map, context));
  }
}

T _enumValue<T>(
    Map<String, Object> map, String name, Context context, List<T> values) {
  final index = getUint(map, name, context, max: values.length - 1, def: 0);
  return values[index < 0 ? 0 : index];
}
