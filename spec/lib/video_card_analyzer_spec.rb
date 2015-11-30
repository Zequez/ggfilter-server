describe VideoCardAnalyzer do
  describe '#tokens' do
    def ana
      @ana ||= VideoCardAnalyzer.new
    end

    [
      [
        'NVIDIA GeForce 6800 or ATI Radeon x1950 256 Mb and higher',
        %w{nvidia6800 amd1950 256mb}
      ],
      [
        'ATI or Nvidia, must support GLSL 2.1, minimum resolution 1280 x 720',
        %w{amd nvidia 1280x720}
      ],
      [
        'NVidia GeForce 8800, ATI/AMD Radeon HD 2400 (NVidia GeForce 8800, ATI/AMD Radeon HD 2400)',
        %w{nvidia8800 amd2400}
      ],
      [
        'NVIDIA Geforce 860m',
        %w{nvidia860m}
      ],
      [
        'NVidia GeForce 7800 / ATI Radeon X1800 or above graphics adapter recommended',
        %w{nvidia7800 amd1800}
      ],
      [
        'OpenGL compatible. ATI, NVIDIA or Intel HD. Older Intel graphics cards may have slowdown issues.',
        %w{opengl amd nvidia intel}
      ],
      [
        'OpenGL 3.2 (DirectX 10 equivalent) graphics card: ATI/AMD Radeon HD 2xxx or higher, NVIDIA GeForce 8xxx or higher.',
        %w{opengl3 directx10 amd2xxx nvidia8xxx}
      ],
      [
        'A 128MB Video Card (Shader Model 3) - Nvidia GeForce 6600 GT / ATI X1600, or equivalent',
        %w{128mb nvidia6600 amd1600}
      ],
      [
        'NVIDIA GeForce 470 GTX or AMD Radeon 6870 HD series card or higher',
        %w{nvidia470 amd6870}
      ],
      [
        'nVidia GeForce FX 5500 / ATI Radeon 9500',
        %w{nvidia5500 amd9500}
      ],
      [
        'NVidia Geforce 275 GTX +512mb memory',
        %w{nvidia275 512mb}
      ],
      [
        '512 MB NVIDIA GeForce 8800 GT, AMD Radeon HD 2900 XT or Intel HD 4000',
        %w{512mb nvidia8800 amd2900 intel4000}
      ],
      [
        'Intel HD3000, Nvidia GeForce GT8600 or equivalent',
        %w{intel3000 nvidia8600}
      ],
      [
        '256 MB 100% DIRECTX 9 AND SHADERS 3.0 COMPATIBLE ATI RADEON HD 2600 XT/NVIDIA GEFORCE 8600 GT OR HIGHER',
        %w{256mb directx9 amd2600 nvidia8600}
      ],
      [
        'ATI Radeon X1900 GT 256MB and the Nvidia GeForce 6800 Ultra 256MB PCI-E cards (Shader Model 2.0 and 24bit depth buffer support required)',
        %w{amd1900 256mb nvidia6800}
      ],
      [
        'DirectX® 11 compatible card with 1 GB of memory, nVidia® 4XX+/AMD® 5XXX+',
        %w{directx11 1gb nvidia4xx amd5xxx}
      ],
      [
        'NVIDIA GeForce 4 MX or better, ATI Radeon 8500 or better, Intel i915 chipset or better 1024x600 resolution',
        %w{nvidia4 amd8500 intel915 1024x600}
      ],
      [
        'Intel 915(900) or better',
        %W{intel915}
      ],
      [
        '512Mb VRAM, Minimum 1024x768 resolution, Intel HD 3000 and higher, GeForce 8800 and higher, AMD Radeon X1600 and higher',
        %w{512mb 1024x768 intel3000 nvidia8800 amd1600}
      ],
      [
        'Video card must be 128 MB or more and should be a DirectX 9-compatible with support for Pixel Shader 2.0b (ATI Radeon X800 or higher / NVIDIA GeForce 7600 or higher / Intel HD Graphics 2000 or higher - *NOT* an Express graphics card).',
        %w{128mb directx9 amd800 nvidia7600 intel2000}
      ],
      [
        'Radeon HD 2600 XT / GeForce 9600 GSO / Intel HD 3000',
        %w{amd2600 nvidia9600 intel3000}
      ],
      [
        '256 MB 3D graphics card - ATI RADEON X1800/NVIDIA GEFORCE 8000/INTEL HD 3000 OR HIGHER',
        %w{256mb amd1800 nvidia8000 intel3000}
      ],
      [
        'Graphics card: DX9 (shader model 2.0) capabilities; generally everything made since 2004 should work.',
        %w{directx9}
      ],
      [
        'Geforce4 4200 or Radeon 9200',
        %w{nvidia44200 amd9200}
      ],
      [
        'Integrated Graphics (256MB)',
        %w{integrated 256mb}
      ],
      [
        'ATI or NVidia card w/ 512 MB RAM (Not recommended for Intel integrated graphics)',
        %w{amd nvidia 512mb}
      ],
      [
        'DirectX 9.0c compatible graphics card / i3 or above integrated graphics.',
        %w{directx9 intel3 integrated}
      ],
      [
        'ATI Radeon X1800, Intel Core i3/i5 HD 733mhz, NVIDIA GeForce 7950 (Intel GMA G43/G45/X4500 or lower video cards not supported)',
        %w{amd1800 intel3 intel5 733mhz nvidia7950}
      ],
      [
        '64MB of video RAM (Integrated graphics may not be supported)',
        %w{64mb}
      ],
      [
        'NVIDIA Geforce 860m',
        %w{nvidia860m}
      ],
      [
        'Radeon HD 7770 or Nvidia GeForce GTX 550 Ti',
        %w{amd7770 nvidia550}
      ],
      [
        'Radeon R9 270x / Geforce GTX 660',
        %w{amd270 nvidia660}
      ],
      [
        'Intel HD series 5000 (or better) or Discreet video card',
        %w{intel5000}
      ],
      [
        'Intel Iris Pro Graphics 5200',
        %w{intel5200}
      ],
      [
        'Intel GMA 950 GeForce 7 Series Radeon X1000 series',
        %w{intel950 nvidia7 amd1000}
      ],
      [
        'Nvidia GT400 series with 512MB RAM or better, ATI 4870HD with 512MB RAM or better',
        %w{nvidia400 512mb amd4870}
      ],
      [
        'Intel Graphics Media Accelerator 4500MHD or equivalent',
        %w{intel4500}
      ],
      [
        'NVIDIA GeForce GTX 770 or AMD GPU Radeon R9 290',
        %w{nvidia770 amd290}
      ],
      [
        '256 MB Video Card using Shader Model 3 (Nvidia GeForce 7800GT or any Nvidia GT200 series or better, ATI X1900 or any HD3600 series or better',
        %w{256mb nvidia7800 nvidia200 amd1900} # or add amd3600 ?
      ],
      [
        'nVidia 570 or similar ATI, 1GB dedicated video memory, Pixel Shaders 3.0',
        %w{nvidia570 amd 1gb}
      ],
      [
        'OpenGL 3.0 compliant with 1.0GB of video RAM.',
        %w{opengl3 1gb}
      ],
      [
        'nVidia GeForce256 or TNT2 ultra, PowerVR Kyro, S3 Savage2000, 3Dfx Voodoo3, ATI Rage128 pro',
        %w{nvidia256 amd128}
      ],
      [
        'NvidiaGeforce 9600GT, ATI Radeon 4670HD or equivalent',
        %w{nvidia9600 amd4670}
      ],
      [
        'Direct3D compatible VRAM32MB or faster 3D Accelerator Card',
        %w{32mb}
      ],
      [
        'Nvidia GeForce 8600+ / AMD Radeon HD X2600+',
        %w{nvidia8600 amd2600}
      ],
      [
        'NVidia Geforce FX, 6x00, 7x00, 8x00, 9x00 and GTX 2x0 and newer. ATI Radeon 9x00, Xx00, X1x00, HD2x00 and HD3x00 series and newer. Intel® HD Graphics NVidia Geforce FX, 6x00, 7x00, 8x00, 9x00 and GTX 2x0 and newer. ATI Radeon 9x00, Xx00, X1x00, HD2x00 and HD3x00 series and newer. Intel® HD Graphics nvidia 6x00 7x00 8x00 9x00 2x0 amd x1x002x003x00 intel',
        %w{nvidia amd intel}
      ],
      [
        '128 MB OpenGL 3D video card supporting Shaders 2.0 (NVIDIA GeForce FX 5600 or better)',
        %w{128mb opengl nvidia5600}
      ],
      [
        'nVidia Geforece 8600GT (9600GT) DDR2 / ATI HD 3670 (HD 4670) DDR2',
        %w{nvidia8600 amd3670}
      ],
      [
        'NVidia Geforce 9xxx / AMD Radeon HD / IntelHD 3000 series or better',
        %w{nvidia9xxx amd intel3000}
      ],
      [
        'Nvidia 8600 GT (256Mbyte) / ATI Radeon HD3650 (256Mbyte)',
        %w{nvidia8600 256mb amd3650}
      ],
      [
        'DirectX 9 compatible 256 MB graphics card with support for pixel/vertex shader 3.0 (GeForce 6/Radeon x1x00 and above)',
        %w{directx9 256mb nvidia6 amd}
      ],
      [
        'GeForceFX5200, RADEON 9500 GeForce8600/RADEON HD2600',
        %w{nvidia5200 amd9500 nvidia8600 amd2600}
      ],
      [
        'nVidia® GeForceTM 5700 or ATI Radeon® 9500',
        %w{nvidia5700 amd9500}
      ],
      [
        'GeForceGTX 650 Ti or better w/ 1024MB VRAM',
        %w{nvidia650 1024mb}
      ],
      [
        'GeForce6600 or better, RadeonX1600 or better, VRAM256MB or more',
        %w{nvidia6600 amd1600 256mb}
      ]
    ].each do |test|
      it test[0] do
        expect(ana.tokens(test[0])).to eq test[1]
      end
    end

    # it{ expect(tokens('NVIDIA GeForce 6800 or ATI Radeon x1950 256 Mb and higher'))
    #     .to eq(%w{nvidia6800 amdx1950 256mb}) }

    # it{ expect(tokens('nvidia')).to eq({'nvidia' => 1})}
  end
end
