// Small in-memory asset shared by the MPEG integration tests.
Map<String, Object> mpegTestAsset() => <String, Object>{
      'asset': <String, Object>{'version': '2.0'},
      'extensionsUsed': <Object>[
        'MPEG_texture_video',
        'MPEG_sampler_YCbCr',
        'MPEG_primitive_V3C',
      ],
      'buffers': <Object>[
        <String, Object>{'byteLength': 44, 'uri': 'data.bin'}
      ],
      'bufferViews': <Object>[
        <String, Object>{'buffer': 0, 'byteLength': 4},
        <String, Object>{'buffer': 0, 'byteOffset': 4, 'byteLength': 4},
        <String, Object>{'buffer': 0, 'byteOffset': 8, 'byteLength': 36},
      ],
      'accessors': <Object>[
        for (var i = 0; i < 2; i++)
          <String, Object>{
            'bufferView': i,
            'componentType': 5121,
            'count': 4,
            'type': 'SCALAR',
          },
        <String, Object>{
          'bufferView': 2,
          'componentType': 5126,
          'count': 3,
          'type': 'VEC3',
          'min': <Object>[0, 0, 0],
          'max': <Object>[1, 1, 1],
        },
      ],
      'samplers': <Object>[
        <String, Object>{
          'extensions': <String, Object>{
            'MPEG_sampler_YCbCr': <String, Object>{},
          },
        },
      ],
      'textures': <Object>[
        <String, Object>{
          'sampler': 0,
          'extensions': <String, Object>{
            'MPEG_texture_video': <String, Object>{
              'accessor': 0,
              'width': 2,
              'height': 2,
              'format': 'RED',
            },
          },
        },
      ],
      'meshes': <Object>[
        <String, Object>{
          'primitives': <Object>[
            <String, Object>{
              'mode': 0,
              'attributes': <String, Object>{'POSITION': 2},
              'extensions': <String, Object>{
                'MPEG_primitive_V3C': <String, Object>{
                  '_MPEG_V3C_CONFIG': 0,
                  '_MPEG_V3C_AD': <String, Object>{'accessor': 1},
                  '_MPEG_V3C_GVD_MAPS': <Object>[0],
                },
              },
            },
          ],
        },
      ],
    };

Map<String, Object> videoProperties(Map<String, Object> asset) =>
    (((asset['textures'] as List)[0] as Map)['extensions']
        as Map)['MPEG_texture_video'] as Map<String, Object>;

Map<String, Object> v3cProperties(Map<String, Object> asset) =>
    (((((asset['meshes'] as List)[0] as Map)['primitives'] as List)[0]
            as Map)['extensions'] as Map)['MPEG_primitive_V3C']
        as Map<String, Object>;
