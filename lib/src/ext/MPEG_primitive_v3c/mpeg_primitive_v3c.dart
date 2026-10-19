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

library gltf.extensions.mpeg_primitive_v3c;

import 'package:gltf/gltf.dart';
import 'package:gltf/src/base/gltf_property.dart';

const String CONFIG = "_MPEG_V3C_CONFIG";
const String ATLAS = "_MPEG_V3C_AD";
const String GEOMETRY_MAPS = "_MPEG_V3C_GVD_MAPS";
const String OCCUPANCY_MAP = "_MPEG_V3C_OVD_MAP";
const String ATTRIBUTE = "_MPEG_V3C_AVD";
const String COMMON_ATLAS_DATA = "_MPEG_V3C_CAD";

const String BUFFER_FORMAT = "buffer_format";
const String ATLAS_ACCESSOR = "accessor";
const String BUFFER_FORMAT_BASELINE = "baseline";
const String BUFFER_FORMAT_EXTENDED = "extended";
const String BUFFER_FORMAT_MIV = "miv";

const List<String> BUFFER_FORMAT_LIST = [
  BUFFER_FORMAT_BASELINE,
  BUFFER_FORMAT_EXTENDED,
  BUFFER_FORMAT_MIV
];

const String ATTRIBUTE_TYPE = "type";
const String ATTRIBUTE_MAPS = "maps";

const String MIV_VIEW_PARAMETERS = "MIV_view_parameters";

const List<String> MPEG_PRIMITIVE_V3C_PROPERTIES = <String>[
  CONFIG,
  ATLAS,
  GEOMETRY_MAPS,
  OCCUPANCY_MAP,
  ATTRIBUTE,
  COMMON_ATLAS_DATA
];

const List<String> MPEG_PRIMITIVE_V3C_AD_PROPERTIES = <String>[
  BUFFER_FORMAT,
  ATLAS_ACCESSOR
];

const List<String> MPEG_PRIMITIVE_V3C_CAD_PROPERTIES = <String>[
  MIV_VIEW_PARAMETERS
];

const List<String> MPEG_PRIMITIVE_V3C_AVD_PROPERTIES = <String>[
  ATTRIBUTE_TYPE,
  ATTRIBUTE_MAPS
];

const Extension mpegPrimitiveV3CExtension = Extension(
    'MPEG_primitive_V3C', <Type, ExtensionDescriptor>{
  MeshPrimitive: ExtensionDescriptor(MPEGPrimitiveV3C.fromMap, localLink: true)
});

class V3C_AD extends GltfProperty {
  final String bufferFormat;
  final int accessor;

  V3C_AD._(this.bufferFormat, this.accessor, Map<String, Object> extensions,
      Object extras)
      : super(extensions, extras);

  static V3C_AD fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_PRIMITIVE_V3C_AD_PROPERTIES, context);
    }

    final bufferFormat = getString(map, BUFFER_FORMAT, context,
        def: 'baseline', list: BUFFER_FORMAT_LIST);
    final accessor = getIndex(map, ATLAS_ACCESSOR, context, req: true);

    return V3C_AD._(bufferFormat, accessor, getExtensions(map, V3C_AD, context),
        getExtras(map, context));
  }
}

class V3C_AVD extends GltfProperty {
  final String type;
  final List<int> maps;

  V3C_AVD._(this.type, this.maps, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static V3C_AVD fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_PRIMITIVE_V3C_AVD_PROPERTIES, context);
    }

    final type = getString(map, ATTRIBUTE_TYPE, context);
    final maps = getIndicesList(map, ATTRIBUTE_MAPS, context, req: true);

    return V3C_AVD._(type, maps, getExtensions(map, V3C_AVD, context),
        getExtras(map, context));
  }
}

class V3C_CAD extends GltfProperty {
  final int miv_view_parameters;

  V3C_CAD._(
      this.miv_view_parameters, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static V3C_CAD fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_PRIMITIVE_V3C_CAD_PROPERTIES, context);
    }
    final miv_view_parameters = getIndex(map, MIV_VIEW_PARAMETERS, context);

    return V3C_CAD._(miv_view_parameters, getExtensions(map, V3C_CAD, context),
        getExtras(map, context));
  }
}

class MPEGPrimitiveV3C extends GltfProperty {
  final int atlasConfig;
  final int occupancyMap;
  final V3C_AD atlas;
  final List<int> geometry;
  final SafeList<V3C_AVD> attributes;
  final V3C_CAD commonAtlasData;

  MPEGPrimitiveV3C._(
      this.atlasConfig,
      this.atlas,
      this.occupancyMap,
      this.geometry,
      this.attributes,
      this.commonAtlasData,
      Map<String, Object> extensions,
      Object extras)
      : super(extensions, extras);

  static MPEGPrimitiveV3C fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_PRIMITIVE_V3C_PROPERTIES, context);
    }

    final config = getIndex(map, CONFIG, context, req: true);
    final occupancy = getIndex(map, OCCUPANCY_MAP, context, req: false);

    SafeList<V3C_AVD> attributes;
    final attribute_maps =
        map.containsKey(ATTRIBUTE) ? getMapList(map, ATTRIBUTE, context) : null;
    if (attribute_maps != null) {
      attributes = SafeList<V3C_AVD>(attribute_maps.length, ATTRIBUTE);
      context.path.add(ATTRIBUTE);
      for (var i = 0; i < attribute_maps.length; i++) {
        final attrMap = attribute_maps[i];
        context.path.add(i.toString());
        attributes[i] = V3C_AVD.fromMap(attrMap, context);
        context.path.removeLast();
      }
      context.path.removeLast();
    } else {
      attributes = SafeList<V3C_AVD>.empty(ATTRIBUTE);
    }

    final atlas =
        getObjectFromInnerMap(map, ATLAS, context, V3C_AD.fromMap, req: true);
    final geometries = getIndicesList(map, GEOMETRY_MAPS, context, req: true);
    final cad =
        getObjectFromInnerMap(map, COMMON_ATLAS_DATA, context, V3C_CAD.fromMap);

    return MPEGPrimitiveV3C._(
        config,
        atlas,
        occupancy,
        geometries,
        attributes,
        cad,
        getExtensions(map, MPEGPrimitiveV3C, context),
        getExtras(map, context));
  }

  @override
  void link(Gltf gltf, Context context) {
    void reference(SafeList<GltfProperty> collection, int index, String name) {
      if (index == -1) return;
      final object = collection[index];
      if (object == null) {
        if (context.validate) {
          context.addIssue(LinkError.unresolvedReference,
              name: name, args: [index]);
        }
      } else if (context.validate) {
        object.markAsUsed();
      }
    }

    void references(
        SafeList<GltfProperty> collection, List<int> indices, String name) {
      if (indices == null) return;
      context.path.add(name);
      for (var i = 0; i < indices.length; i++) {
        reference(collection, indices[i], i.toString());
      }
      context.path.removeLast();
    }

    reference(gltf.accessors, atlasConfig, CONFIG);
    if (atlas != null) {
      context.path.add(ATLAS);
      reference(gltf.accessors, atlas.accessor, ATLAS_ACCESSOR);
      context.path.removeLast();
    }
    reference(gltf.textures, occupancyMap, OCCUPANCY_MAP);
    references(gltf.textures, geometry, GEOMETRY_MAPS);
    context.path.add(ATTRIBUTE);
    attributes.forEachWithIndices((i, attribute) {
      context.path.add(i.toString());
      references(gltf.textures, attribute.maps, ATTRIBUTE_MAPS);
      context.path.removeLast();
    });
    context.path.removeLast();
    if (commonAtlasData != null) {
      context.path.add(COMMON_ATLAS_DATA);
      reference(gltf.accessors, commonAtlasData.miv_view_parameters,
          MIV_VIEW_PARAMETERS);
      context.path.removeLast();
    }
  }
}
