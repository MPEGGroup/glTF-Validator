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

library gltf.extensions.mpeg_media;

import 'package:gltf/src/utils.dart';
import 'package:gltf/src/base/gltf_property.dart';
import 'package:gltf/src/ext/extensions.dart';

const String MPEG_MEDIA = 'MPEG_MEDIA';
//Const members
const String NAME = 'name';
const String STARTTIME = 'startTime';
const String STARTTIMEOFFSET = 'startTimeOffset';
const String ENDTIMEOFFSET = 'endTimeOffset';
const String AUTOPLAY = 'autoplay';
const String AUTOPLAYGROUP = 'autoplayGroup';
const String LOOP = 'loop';
const String CONTROLS = 'controls';
const String ALTERNATIVES = 'alternatives';
const String MEDIA = 'media';

const String URI = 'uri';
const String MIMETYPE = 'mimeType';
const String TRACKS = 'tracks';
const String EXTRAPARAMS = 'extraParams';

const String TRACK = 'track';
const String CODECS = 'codecs';

const List<String> MPEG_MEDIA_OBJECT = [MEDIA];
const List<String> MPEG_MEDIA_OBJECT_MEMBERS = <String>[
  NAME,
  STARTTIME,
  STARTTIMEOFFSET,
  ENDTIMEOFFSET,
  AUTOPLAY,
  AUTOPLAYGROUP,
  LOOP,
  CONTROLS,
  ALTERNATIVES,
];

const List<String> MPEG_MEDIA_OBJECT_ALTERNATIVE_ITEMS = <String>[
  URI,
  MIMETYPE,
  TRACKS,
  EXTRAPARAMS
];

const List<String> MPEG_MEDIA_ALTERNATIVE_TRACK_ITEMS = <String>[TRACK, CODECS];

const Extension mpegMediaExtension =
    Extension('MPEG_media', <Type, ExtensionDescriptor>{
  Gltf: ExtensionDescriptor(MPEGMediaObject.fromMap),
  Node: ExtensionDescriptor(MPEGMedia.fromMap)
});

class MPEGMediaObject extends GltfProperty {
  final SafeList<MPEGMedia> media;
  MPEGMediaObject._(this.media, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static MPEGMediaObject fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_MEDIA_OBJECT, context);
    }

    SafeList<MPEGMedia> media;
    final mediaMaps = getMapList(map, MEDIA, context);
    if (mediaMaps != null) {
      media = SafeList<MPEGMedia>(mediaMaps.length, MEDIA);
      context.path.add(MEDIA);
      for (var i = 0; i < mediaMaps.length; i++) {
        final mediaMap = mediaMaps[i];
        context.path.add(i.toString());
        media[i] = MPEGMedia.fromMap(mediaMap, context);
        context.path.removeLast();
      }
      context.path.removeLast();
    } else {
      media = SafeList<MPEGMedia>.empty(MEDIA);
    }

    return MPEGMediaObject._(media,
        getExtensions(map, MPEGMediaObject, context), getExtras(map, context));
  }

  MPEGMedia getMpegMedia(int index) {
    MPEGMedia _media;
    if (index < media.length) {
      _media = media[index];
    }
    return _media;
  }

  @override
  void link(Gltf gltf, Context context) {
    if (media != null) {
      context.path.add(MEDIA);
      context.extensionCollections[media] =
          context.path.toList(growable: false);
      media.forEachWithIndices((index, element) {
        context.path.add(index.toString());
        element.link(gltf, context);
        context.path.removeLast();
      });
      context.path.removeLast();
    }
  }
}

class MPEGMedia extends GltfProperty {
  final String name;
  final double startTime;
  final double startTimeOffset;
  final double endTimeOffset;
  final bool autoplay;
  final bool autoplayGroup;
  final bool loop;
  final bool controls;
  final SafeList<MPEGMediaAlternatives> alternatives;

  MPEGMedia._(
      this.name,
      this.startTime,
      this.startTimeOffset,
      this.endTimeOffset,
      this.autoplay,
      this.autoplayGroup,
      this.loop,
      this.controls,
      this.alternatives,
      Map<String, Object> extensions,
      Object extras)
      : super(extensions, extras);

  static MPEGMedia fromMap(Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_MEDIA_OBJECT_MEMBERS, context);
    }

    //todo set defaults values
    final name = getString(map, NAME, context);
    final startTime = getFloat(map, STARTTIME, context);
    final startTimeOffset = getFloat(map, STARTTIMEOFFSET, context, def: 0.0);
    final endStartTime = getFloat(map, ENDTIMEOFFSET, context);
    final autoplay = getBool(map, AUTOPLAY, context);
    final autoplaygroup = getBool(map, AUTOPLAYGROUP, context);
    final loop = getBool(map, LOOP, context);
    final controls = getBool(map, CONTROLS, context);

    SafeList<MPEGMediaAlternatives> alt;
    final altMaps = getMapList(map, ALTERNATIVES, context);
    if (altMaps != null) {
      alt = SafeList<MPEGMediaAlternatives>(altMaps.length, ALTERNATIVES);
      context.path.add(ALTERNATIVES);
      for (var i = 0; i < altMaps.length; i++) {
        final altMap = altMaps[i];
        context.path.add(i.toString());
        alt[i] = MPEGMediaAlternatives.fromMap(altMap, context);
        context.path.removeLast();
      }
      context.path.removeLast();
    } else {
      alt = SafeList<MPEGMediaAlternatives>.empty(ALTERNATIVES);
    }

    return MPEGMedia._(
        name,
        startTime,
        startTimeOffset,
        endStartTime,
        autoplay,
        autoplaygroup,
        loop,
        controls,
        alt,
        getExtensions(map, MPEGMedia, context),
        getExtras(map, context));
  }
}

class MPEGMediaAlternatives extends GltfProperty {
  final String mimeType;
  final String uri;
  final SafeList<MPEGMediaAlternativesTracks> tracks;
  final Object extraParams;

  MPEGMediaAlternatives._(this.mimeType, this.uri, this.tracks,
      this.extraParams, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static MPEGMediaAlternatives fromMap(
      Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_MEDIA_OBJECT_ALTERNATIVE_ITEMS, context);
    }
    final mimeType = getString(map, MIMETYPE, context, req: true);
    final uri = getString(map, URI, context, req: true);
    final extraParams = map[EXTRAPARAMS];
    SafeList<MPEGMediaAlternativesTracks> tracks;
    final trackMaps =
        map.containsKey(TRACKS) ? getMapList(map, TRACKS, context) : null;
    if (trackMaps != null) {
      tracks = SafeList<MPEGMediaAlternativesTracks>(trackMaps.length, TRACKS);
      context.path.add(TRACKS);
      for (var i = 0; i < trackMaps.length; i++) {
        final trackmap = trackMaps[i];
        context.path.add(i.toString());
        tracks[i] = MPEGMediaAlternativesTracks.fromMap(trackmap, context);
        context.path.removeLast();
      }
      context.path.removeLast();
    } else {
      tracks = SafeList<MPEGMediaAlternativesTracks>.empty(TRACKS);
    }

    return MPEGMediaAlternatives._(
        mimeType,
        uri,
        tracks,
        extraParams,
        getExtensions(map, MPEGMediaAlternatives, context),
        getExtras(map, context));
  }
}

class MPEGMediaAlternativesTracks extends GltfProperty {
  final String track;
  final String codecs;

  MPEGMediaAlternativesTracks._(
      this.track, this.codecs, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static MPEGMediaAlternativesTracks fromMap(
      Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MPEG_MEDIA_ALTERNATIVE_TRACK_ITEMS, context);
    }

    final track = getString(map, TRACK, context, req: true);
    final codecs = getString(map, CODECS, context, req: true);

    return MPEGMediaAlternativesTracks._(
        track,
        codecs,
        getExtensions(map, MPEGMediaAlternativesTracks, context),
        getExtras(map, context));
  }
}
