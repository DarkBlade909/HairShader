// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DarkbladeHair"
{
	Properties
	{
		[NoScaleOffset][Header(Hair Shader V1.0 by DarkBlade909)][Header(____________Main Textures____________)][Space(5)]_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (0.5176471,0.3686275,0.2705882,1)
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.15
		[NoScaleOffset]_BumpMap("NormalMap", 2D) = "bump" {}
		_NormalStrength("NormalStrength", Float) = 1
		_Occlusion("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range( 0 , 1)) = 1
		[Toggle(_USEALBEDOASOCCLUSION_ON)] _UseAlbedoasOcclusion("Use Albedo as Occlusion", Float) = 1
		[Space(50)][Header(____________Anisotropy____________)][Space(5)]_Anisotropy("Anisotropy", Range( -1 , 1)) = -1
		_AnisotropicColor("Anisotropic Color", Color) = (0.3568628,0.2666667,0.2,1)
		_AnisotropicSmoothness("Anisotropic Smoothness", Range( 0 , 1)) = 0.75
		_AnisoNormalStrength("AnisoNormalStrength", Float) = 0.5
		[Space(50)][Header(____________Misc Settings____________)][Space(5)][Toggle(_RIMLIGHTINGFIX_ON)] _RimLightingFix("Rim Lighting Fix", Float) = 1
		_SurfaceLightingStrength("Surface Lighting Strength", Range( 0 , 1)) = 1
		_WindStrength("Wind Strength", Range( 0 , 1)) = 0.1
		_WindTurbulence("Wind Turbulence", Range( 0 , 10)) = 0.5
		_WindVerticalMasking("Wind Vertical Masking", Range( 0 , 1)) = 1
		[NoScaleOffset]_WindHairMask("Wind Hair Mask", 2D) = "white" {}
		_MaskClip("Mask Clip", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _USEALBEDOASOCCLUSION_ON
		#pragma shader_feature_local _RIMLIGHTINGFIX_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			half ASEVFace : VFACE;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _MainTex;
		uniform float _WindVerticalMasking;
		uniform float _WindTurbulence;
		uniform float _WindStrength;
		uniform sampler2D _WindHairMask;
		uniform float4 _Color;
		uniform float _MaskClip;
		uniform sampler2D _BumpMap;
		uniform float _AnisoNormalStrength;
		uniform float _AnisotropicSmoothness;
		uniform float _Anisotropy;
		uniform float4 _AnisotropicColor;
		uniform sampler2D _Occlusion;
		uniform float _OcclusionStrength;
		uniform float _NormalStrength;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _SurfaceLightingStrength;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_WindHairMask177 = i.uv_texcoord;
			float2 appendResult62 = (float2(( ( 1.0 - ( _WindVerticalMasking * i.uv_texcoord.y ) ) * ( sin( ( ( ( _Time.y * _WindTurbulence ) + i.uv_texcoord.y ) * 15.0 ) ) * ( _WindStrength * 0.01 ) ) * tex2D( _WindHairMask, uv_WindHairMask177 ) ).rg));
			float2 HairWaveUV63 = ( i.uv_texcoord + appendResult62 );
			float4 Albedo90 = ( tex2D( _MainTex, HairWaveUV63 ) * _Color );
			float3 NormalMap95 = UnpackScaleNormal( tex2D( _BumpMap, HairWaveUV63 ), _AnisoNormalStrength );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 newWorldNormal6_g49 = (WorldNormalVector( i , ( NormalMap95 + ase_vertexNormal ) ));
			float3 normalizeResult3_g49 = normalize( newWorldNormal6_g49 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g51 = normalize( ( ase_worldViewDir + ( ase_worldlightDir < float3( -1,-1,-1 ) ? float3(0,0.5,1) : ase_worldlightDir ) ) );
			float3 temp_output_44_0_g49 = normalizeResult4_g51;
			float dotResult27_g49 = dot( normalizeResult3_g49 , temp_output_44_0_g49 );
			float temp_output_32_0_g49 = max( dotResult27_g49 , 0.0 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float dotResult13_g49 = dot( temp_output_44_0_g49 , ( NormalMap95 + ase_worldTangent ) );
			float temp_output_20_0_g49 = ( 1.0 - _AnisotropicSmoothness );
			float temp_output_21_0_g49 = ( temp_output_20_0_g49 * temp_output_20_0_g49 );
			half2 _half = half2(1,0.9);
			float temp_output_18_0_g49 = sqrt( ( _half.x - ( _Anisotropy * _half.y ) ) );
			float temp_output_38_0_g49 = ( max( ( temp_output_21_0_g49 / temp_output_18_0_g49 ) , 0.001 ) * 5 );
			float temp_output_28_0_g49 = ( dotResult13_g49 / temp_output_38_0_g49 );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float dotResult14_g49 = dot( temp_output_44_0_g49 , ase_worldBitangent );
			float temp_output_39_0_g49 = ( max( ( temp_output_18_0_g49 * temp_output_21_0_g49 ) , 0.001 ) * 5 );
			float temp_output_33_0_g49 = ( dotResult14_g49 / temp_output_39_0_g49 );
			float temp_output_36_0_g49 = ( ( temp_output_32_0_g49 * temp_output_32_0_g49 ) + ( temp_output_28_0_g49 * temp_output_28_0_g49 ) + ( temp_output_33_0_g49 * temp_output_33_0_g49 ) );
			float clampResult54 = clamp( ( 1.0 / ( ( temp_output_36_0_g49 * temp_output_36_0_g49 ) * temp_output_38_0_g49 * temp_output_39_0_g49 * UNITY_PI ) ) , 0.0 , 2.0 );
			#ifdef _USEALBEDOASOCCLUSION_ON
				float4 staticSwitch238 = tex2D( _MainTex, HairWaveUV63 );
			#else
				float4 staticSwitch238 = tex2D( _Occlusion, HairWaveUV63 );
			#endif
			float4 lerpResult225 = lerp( float4( 1,1,1,1 ) , staticSwitch238 , _OcclusionStrength);
			float4 Occlusion214 = lerpResult225;
			UnityGI gi173 = gi;
			float3 diffNorm173 = ase_worldNormal;
			gi173 = UnityGI_Base( data, 1, diffNorm173 );
			float3 indirectDiffuse173 = gi173.indirect.diffuse + diffNorm173 * 0.0001;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float FallbackDirectional146 = ( ase_worldlightDir.x == float3( 0,0.5,1 ) ? 1.0 : 0.0 );
			float4 lerpResult237 = lerp( ase_lightColor , float4( 1,1,1,1 ) , FallbackDirectional146);
			float4 Anisotropy187 = ( clampResult54 * _AnisotropicColor * Occlusion214 * float4( indirectDiffuse173 , 0.0 ) * lerpResult237 );
			SurfaceOutputStandard s32 = (SurfaceOutputStandard ) 0;
			s32.Albedo = Albedo90.rgb;
			float3 HairNormal99 = UnpackScaleNormal( tex2D( _BumpMap, HairWaveUV63 ), _NormalStrength );
			s32.Normal = WorldNormalVector( i , HairNormal99 );
			s32.Emission = float3( 0,0,0 );
			s32.Metallic = _Metallic;
			float Smoothness200 = _Smoothness;
			s32.Smoothness = Smoothness200;
			s32.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi32 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g32 = UnityGlossyEnvironmentSetup( s32.Smoothness, data.worldViewDir, s32.Normal, float3(0,0,0));
			gi32 = UnityGlobalIllumination( data, s32.Occlusion, s32.Normal, g32 );
			#endif

			float3 surfResult32 = LightingStandard ( s32, viewDir, gi32 ).rgb;
			surfResult32 += s32.Emission;

			#ifdef UNITY_PASS_FORWARDADD//32
			surfResult32 -= s32.Emission;
			#endif//32
			float3 switchResult205 = (((i.ASEVFace>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV178 = dot( switchResult205, ase_worldViewDir );
			float fresnelNode178 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV178, 3.0 ) );
			float clampResult182 = clamp( ( 1.0 - fresnelNode178 ) , 0.2 , 1.0 );
			float clampResult195 = clamp( Smoothness200 , 0.0 , 0.333 );
			float lerpResult193 = lerp( 1.0 , clampResult182 , ( clampResult195 * 3.0 ));
			#ifdef _RIMLIGHTINGFIX_ON
				float staticSwitch198 = lerpResult193;
			#else
				float staticSwitch198 = 1.0;
			#endif
			float RimLightFix202 = staticSwitch198;
			float temp_output_141_0 = ( FallbackDirectional146 + 1.0 );
			float4 appendResult145 = (float4(temp_output_141_0 , temp_output_141_0 , temp_output_141_0 , temp_output_141_0));
			float4 SurfaceShading189 = ( float4( surfResult32 , 0.0 ) * _SurfaceLightingStrength * RimLightFix202 * appendResult145 * Occlusion214 );
			c.rgb = ( Anisotropy187 + SurfaceShading189 ).rgb;
			c.a = ( ( _MaskClip - 0.5 ) + (Albedo90).a );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_WindHairMask177 = i.uv_texcoord;
			float2 appendResult62 = (float2(( ( 1.0 - ( _WindVerticalMasking * i.uv_texcoord.y ) ) * ( sin( ( ( ( _Time.y * _WindTurbulence ) + i.uv_texcoord.y ) * 15.0 ) ) * ( _WindStrength * 0.01 ) ) * tex2D( _WindHairMask, uv_WindHairMask177 ) ).rg));
			float2 HairWaveUV63 = ( i.uv_texcoord + appendResult62 );
			float4 Albedo90 = ( tex2D( _MainTex, HairWaveUV63 ) * _Color );
			o.Albedo = Albedo90.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;695;1402;344;4632.831;-1494.097;2.125837;True;False
Node;AmplifyShaderEditor.CommentaryNode;183;-1713.241,1293.328;Inherit;False;1832.61;634.4746;;18;80;62;86;87;177;82;85;74;175;81;83;176;79;56;71;123;72;63;Wind Effects;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-1685.015,1626.212;Inherit;False;Property;_WindTurbulence;Wind Turbulence;17;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;72;-1546.247,1526.16;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;-1562.974,1362.982;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1360.247,1527.16;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1220.312,1528.168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-1103.059,1529.558;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1240.057,1621.617;Inherit;False;Property;_WindStrength;Wind Strength;16;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-1252.566,1435.175;Inherit;False;Property;_WindVerticalMasking;Wind Vertical Masking;18;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;74;-978.1254,1531.483;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-990.5303,1436.461;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-978.3204,1625.49;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-852.3406,1533.016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;177;-1136.644,1723.426;Inherit;True;Property;_WindHairMask;Wind Hair Mask;19;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;87;-866.8835,1435.853;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-688.9921,1507.595;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;204;-1703.868,734.7557;Inherit;False;1664.469;414.9399;;13;202;198;193;199;197;182;195;179;178;201;205;209;208;Rim Light Fix;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;62;-540.889,1504.811;Inherit;True;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;208;-1694.012,894.0711;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;192;-3022.271,478.825;Inherit;False;1241.12;674.2061;;14;189;133;203;32;145;215;89;100;141;51;91;147;200;4;Standard Shading;1,1,1,1;0;0
Node;AmplifyShaderEditor.NegateNode;209;-1505.972,954.6937;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-3012.179,705.9524;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0.15;0.18;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-295.772,1360.97;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwitchByFaceNode;205;-1378.465,894.8568;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;186;-3018.625,-109.6716;Inherit;False;816.1256;455.3055;;8;99;46;29;95;65;25;64;48;Normal Maps;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-2715.265,705.8293;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-174.8316,1360.52;Inherit;False;HairWaveUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;185;-3019.278,-693.5346;Inherit;False;958.1433;461.7664;;5;66;52;3;53;90;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;219;-3036.459,2348.491;Inherit;False;1265.448;789.9587;;7;214;225;226;213;238;239;242;Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-2962.327,-45.47973;Inherit;False;63;HairWaveUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;178;-1185.142,890.6898;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2998.101,31.83729;Inherit;False;Property;_AnisoNormalStrength;AnisoNormalStrength;13;0;Create;True;0;0;0;False;0;False;0.5;5.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;184;-1696.434,437.4953;Inherit;False;612.6;209.7999;;3;146;140;139;Light Detection;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-1085.419,769.2304;Inherit;False;200;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2960.348,-594.1837;Inherit;False;63;HairWaveUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;139;-1664.747,496.3463;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;242;-3024.887,2551.278;Inherit;False;63;HairWaveUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;179;-906.0445,890.4182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-2715.47,-44.59875;Inherit;True;Property;_BumpMap;NormalMap;5;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;04f1a98ea40ce984393219143fdb66b9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;195;-908.1456,768.608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.333;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;182;-766.7812,889.5395;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;213;-2798.25,2417.461;Inherit;True;Property;_Occlusion;Occlusion;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;52;-2778.449,-618.6318;Inherit;True;Property;_MainTex;Albedo;0;1;[NoScaleOffset];Create;False;0;0;0;False;3;Header(Hair Shader V1.0 by DarkBlade909);Header(____________Main Textures____________);Space(5);False;-1;None;38835bd03265fff48a118a6b88e5d42d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-2417.247,-45.21471;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2965.29,239.1135;Inherit;False;Property;_NormalStrength;NormalStrength;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-762.2617,770.5224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-2690.872,-427.3498;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;0.5176471,0.3686275,0.2705882,1;0.517647,0.3686274,0.2705881,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;239;-2797.285,2609.245;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;52;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2964.422,159.8693;Inherit;False;63;HairWaveUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Compare;140;-1454.706,495.3862;Inherit;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0.5,1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;191;-3029.681,1299.416;Inherit;False;1264.512;936.2068;;18;187;49;173;54;217;234;50;128;35;30;44;26;38;96;233;97;236;237;Anisotropy;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexTangentNode;38;-2925.583,1631.942;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;233;-2926.248,1413.861;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-2416.378,-488.7607;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;46;-2716.189,156.7275;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;25;None;None;True;0;False;white;Auto;True;Instance;25;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2924.998,1343.271;Inherit;False;95;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-2926.644,1561.309;Inherit;False;95;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-1311.9,494.7112;Inherit;False;FallbackDirectional;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;238;-2471.781,2515.965;Inherit;False;Property;_UseAlbedoasOcclusion;Use Albedo as Occlusion;9;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;226;-2796.563,2806.927;Inherit;False;Property;_OcclusionStrength;Occlusion Strength;8;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;193;-616.3511,860.8999;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-612.754,782.5202;Inherit;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2289.248,-488.8726;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-2672.533,1579.944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2925.353,1860.982;Inherit;False;Property;_AnisotropicSmoothness;Anisotropic Smoothness;12;0;Create;True;0;0;0;False;0;False;0.75;0.815;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2925.226,1779.478;Inherit;False;Property;_Anisotropy;Anisotropy;10;0;Create;True;0;0;0;False;3;Space(50);Header(____________Anisotropy____________);Space(5);False;-1;0.978;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-2416.552,156.4204;Inherit;False;HairNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;225;-2173.467,2513.584;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;1,1,1,1;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-2802.328,929.9456;Inherit;False;146;FallbackDirectional;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2723.276,1403.395;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;198;-466.2892,783.2245;Inherit;False;Property;_RimLightingFix;Rim Lighting Fix;14;0;Create;True;0;0;0;False;3;Space(50);Header(____________Misc Settings____________);Space(5);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-2668.562,532.3828;Inherit;False;90;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;234;-2441.129,1994.545;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-2588.556,929.0352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;128;-2502.692,1493.749;Inherit;False;Trowbridge-Reitz Aniso NDF;-1;;49;2a680a5d45b292544abf41ca00dae14a;2,7,0,2,0;7;1;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;44;FLOAT3;0,0,0;False;45;FLOAT3;0,0,0;False;46;FLOAT3;0,0,0;False;15;FLOAT;1;False;19;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;236;-2503.094,2144.778;Inherit;False;146;FallbackDirectional;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-236.7316,781.5858;Inherit;False;RimLightFix;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3011.74,627.9417;Inherit;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-2024.897,2514.462;Inherit;False;Occlusion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-2676.039,613.5408;Inherit;False;99;HairNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;173;-2499.788,1922.148;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2601.433,782.6801;Inherit;False;Property;_SurfaceLightingStrength;Surface Lighting Strength;15;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;-2500.688,1678.833;Inherit;False;Property;_AnisotropicColor;Anisotropic Color;11;0;Create;True;0;0;0;False;0;False;0.3568628,0.2666667,0.2,1;0.4811321,0.3566101,0.274608,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;54;-2236.365,1494.38;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-2505.304,854.7473;Inherit;False;202;RimLightFix;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-2455.714,1845.858;Inherit;False;214;Occlusion;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;145;-2457.53,923.2032;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-2493.949,1060.781;Inherit;False;214;Occlusion;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;237;-2267.725,2035.063;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,1;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;32;-2474.205,574.6636;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-2080.787,1543.227;Inherit;False;5;5;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-2186.193,787.6647;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT4;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2073.809,41.01571;Inherit;False;90;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;-2063.555,786.3223;Inherit;False;SurfaceShading;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-1952.167,1543.838;Inherit;False;Anisotropy;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-2134.435,-55.94446;Inherit;False;Property;_MaskClip;Mask Clip;20;0;Create;True;0;0;0;True;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-2106.419,188.2622;Inherit;False;189;SurfaceShading;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-2081.324,115.3072;Inherit;False;187;Anisotropy;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;94;-1916.028,39.10826;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;212;-1857.717,-54.67308;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-1899.934,140.1468;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;211;-1713.818,-2.373083;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1887.63,-127.67;Inherit;False;90;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1274.774,-102.403;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;DarkbladeHair;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;1;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;210;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;71;0;72;0
WireConnection;71;1;123;0
WireConnection;79;0;71;0
WireConnection;79;1;56;2
WireConnection;81;0;79;0
WireConnection;74;0;81;0
WireConnection;175;0;176;0
WireConnection;175;1;56;2
WireConnection;85;0;83;0
WireConnection;82;0;74;0
WireConnection;82;1;85;0
WireConnection;87;0;175;0
WireConnection;86;0;87;0
WireConnection;86;1;82;0
WireConnection;86;2;177;0
WireConnection;62;0;86;0
WireConnection;209;0;208;0
WireConnection;80;0;56;0
WireConnection;80;1;62;0
WireConnection;205;0;208;0
WireConnection;205;1;209;0
WireConnection;200;0;4;0
WireConnection;63;0;80;0
WireConnection;178;0;205;0
WireConnection;179;0;178;0
WireConnection;25;1;64;0
WireConnection;25;5;48;0
WireConnection;195;0;201;0
WireConnection;182;0;179;0
WireConnection;213;1;242;0
WireConnection;52;1;66;0
WireConnection;95;0;25;0
WireConnection;197;0;195;0
WireConnection;239;1;242;0
WireConnection;140;0;139;0
WireConnection;53;0;52;0
WireConnection;53;1;3;0
WireConnection;46;1;65;0
WireConnection;46;5;29;0
WireConnection;146;0;140;0
WireConnection;238;1;213;0
WireConnection;238;0;239;0
WireConnection;193;1;182;0
WireConnection;193;2;197;0
WireConnection;90;0;53;0
WireConnection;44;0;97;0
WireConnection;44;1;38;0
WireConnection;99;0;46;0
WireConnection;225;1;238;0
WireConnection;225;2;226;0
WireConnection;26;0;96;0
WireConnection;26;1;233;0
WireConnection;198;1;199;0
WireConnection;198;0;193;0
WireConnection;141;0;147;0
WireConnection;128;1;26;0
WireConnection;128;45;44;0
WireConnection;128;15;30;0
WireConnection;128;19;35;0
WireConnection;202;0;198;0
WireConnection;214;0;225;0
WireConnection;54;0;128;0
WireConnection;145;0;141;0
WireConnection;145;1;141;0
WireConnection;145;2;141;0
WireConnection;145;3;141;0
WireConnection;237;0;234;0
WireConnection;237;2;236;0
WireConnection;32;0;91;0
WireConnection;32;1;100;0
WireConnection;32;3;51;0
WireConnection;32;4;200;0
WireConnection;49;0;54;0
WireConnection;49;1;50;0
WireConnection;49;2;217;0
WireConnection;49;3;173;0
WireConnection;49;4;237;0
WireConnection;133;0;32;0
WireConnection;133;1;89;0
WireConnection;133;2;203;0
WireConnection;133;3;145;0
WireConnection;133;4;215;0
WireConnection;189;0;133;0
WireConnection;187;0;49;0
WireConnection;94;0;93;0
WireConnection;212;0;210;0
WireConnection;34;0;188;0
WireConnection;34;1;190;0
WireConnection;211;0;212;0
WireConnection;211;1;94;0
WireConnection;0;0;92;0
WireConnection;0;9;211;0
WireConnection;0;13;34;0
ASEEND*/
//CHKSM=5DDA472C112798BC02BDB750CFDE170CE9E2625E