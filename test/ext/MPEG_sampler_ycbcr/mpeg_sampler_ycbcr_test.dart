import 'package:gltf/gltf.dart';
import 'package:test/test.dart';

import '../mpeg_test_utils.dart';

void main() {
  test('YCbCr sampler is registered with its correct extension name', () {
    final context = Context();
    final gltf = Gltf.fromMap(mpegTestAsset(), context);
    final extension =
        gltf.samplers[0].extensions['MPEG_sampler_YCbCr'] as MPEGSamplerYCbCr;
    expect(extension.ycbcrmodel, YCbCrModel.RGB_IDENTITY);
    expect(extension.ycbcrrange, YCbCrRange.ITU_FULL);
    expect(extension.filter, Filter.NEAREST);
    expect(extension.xChromaOffset, ChromaLocation.COSITED_EVEN);
    expect(extension.yChromaOffset, ChromaLocation.COSITED_EVEN);
    expect(extension.components.r, ComponentSwizzle.COMPOMENT_SWIZZLE_IDENTITY);
    expect(context.errors, isEmpty);
    expect(context.extensionsLoaded, contains('MPEG_sampler_YCbCr'));
  });

  test('allows repeated component swizzles', () {
    final context = Context();
    final extension = MPEGSamplerYCbCr.fromMap(<String, Object>{
      'components': <Object>[0, 0, 0, 0],
    }, context);
    expect(extension.components.a, ComponentSwizzle.COMPOMENT_SWIZZLE_IDENTITY);
    expect(context.issues, isEmpty);
  });

  test('reads explicit enum and component values', () {
    final context = Context();
    final extension = MPEGSamplerYCbCr.fromMap(<String, Object>{
      'ycbcrModel': 4,
      'ycbcrRange': 1,
      'chromaFilter': 2,
      'xChromaOffset': 1,
      'yChromaOffset': 1,
      'components': <Object>[3, 4, 5, 6],
    }, context);
    expect(extension.ycbcrmodel, YCbCrModel.YCBCR_2020);
    expect(extension.ycbcrrange, YCbCrRange.ITU_NARROW);
    expect(extension.filter, Filter.CUBIC);
    expect(extension.xChromaOffset, ChromaLocation.MIDPOINT);
    expect(extension.components.a, ComponentSwizzle.COMPONENT_SWIZZLE_A);
    expect(context.issues, isEmpty);
  });

  for (final name in [
    'ycbcrModel',
    'ycbcrRange',
    'chromaFilter',
    'xChromaOffset',
    'yChromaOffset'
  ]) {
    for (final value in <Object>[-1, 999, '0', 0.5, null]) {
      test(
          'reports invalid $name $value (${value.runtimeType}) without crashing',
          () {
        final context = Context();
        MPEGSamplerYCbCr.fromMap(<String, Object>{name: value}, context);
        expect(context.errors, isNotEmpty);
      });
    }
  }

  for (final value in <Object>[
    null,
    'invalid',
    <Object>[],
    <Object>[0, 0, 0],
    <Object>[0, 0, 0, 0, 0],
    <Object>[0, -1, 0, 0],
    <Object>[0, 7, 0, 0],
    <Object>[0, '1', 0, 0],
    <Object>[0, 0.5, 0, 0],
  ]) {
    test('reports invalid components $value without crashing', () {
      final context = Context();
      MPEGSamplerYCbCr.fromMap(<String, Object>{'components': value}, context);
      expect(context.errors, isNotEmpty);
    });
  }
}
