// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water Caustic"
{
	Properties
	{
		_1ScrollXSpeed("1. Scroll X Speed", Range( -1 , 1)) = 0
		_1ScrollYSpeed("1. Scroll Y Speed", Range( -1 , 1)) = 0
		_2ScrollYSpeed("2. Scroll Y Speed", Range( -1 , 1)) = 0
		_2ScrollXSpeed("2. Scroll X Speed", Range( -1 , 1)) = 0
		_AngleSpeed("Angle Speed", Float) = 0
		_AlphaOffset("Alpha Offset", Float) = 0
		_Emissive("Emissive", Float) = 0
		_NoiseAlphaInfluence("Noise Alpha Influence", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _AngleSpeed;
		uniform float _1ScrollXSpeed;
		uniform float _1ScrollYSpeed;
		uniform float _2ScrollXSpeed;
		uniform float _2ScrollYSpeed;
		uniform float _Emissive;
		uniform float _NoiseAlphaInfluence;
		uniform float _AlphaOffset;


		float2 voronoihash33( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi33( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash33( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.707 * sqrt(dot( r, r ));
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return (F2 + F1) * 0.5;
		}


		float2 voronoihash34( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi34( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash34( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.707 * sqrt(dot( r, r ));
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return (F2 + F1) * 0.5;
		}


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime38 = _Time.y * _AngleSpeed;
			float time33 = mulTime38;
			float4 appendResult15 = (float4(( _Time.y * _1ScrollXSpeed ) , ( _Time.y * _1ScrollYSpeed ) , 0.0 , 0.0));
			float2 uv_TexCoord5 = i.uv_texcoord + appendResult15.xy;
			float2 coords33 = uv_TexCoord5 * 11.22;
			float2 id33 = 0;
			float2 uv33 = 0;
			float fade33 = 0.5;
			float voroi33 = 0;
			float rest33 = 0;
			for( int it33 = 0; it33 <2; it33++ ){
			voroi33 += fade33 * voronoi33( coords33, time33, id33, uv33, 0 );
			rest33 += fade33;
			coords33 *= 2;
			fade33 *= 0.5;
			}//Voronoi33
			voroi33 /= rest33;
			float time34 = mulTime38;
			float4 appendResult31 = (float4(( _Time.y * _2ScrollXSpeed ) , ( _Time.y * _2ScrollYSpeed ) , 0.0 , 0.0));
			float2 uv_TexCoord32 = i.uv_texcoord + appendResult31.xy;
			float2 coords34 = uv_TexCoord32 * 11.22;
			float2 id34 = 0;
			float2 uv34 = 0;
			float voroi34 = voronoi34( coords34, time34, id34, uv34, 0 );
			float temp_output_24_0 = ( voroi33 * voroi34 );
			float3 temp_cast_2 = (( temp_output_24_0 * _Emissive )).xxx;
			o.Emission = temp_cast_2;
			Gradient gradient20 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0, 0, 0, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 appendResult43 = (float4(0.0 , _AlphaOffset , 0.0 , 0.0));
			float2 uv_TexCoord22 = i.uv_texcoord + appendResult43.xy;
			Gradient gradient51 = NewGradient( 0, 4, 2, float4( 0, 0, 0, 0 ), float4( 1, 1, 1, 0.1000076 ), float4( 1, 1, 1, 0.9000076 ), float4( 0, 0, 0, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			o.Alpha = ( ( temp_output_24_0 * _NoiseAlphaInfluence ) * ( SampleGradient( gradient20, uv_TexCoord22.y ) * SampleGradient( gradient51, uv_TexCoord22.x ) ) ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
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
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
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
197;88;2245;1158;2398.727;402.9191;1.041743;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;25;-1723.187,350.567;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1892.753,-28.28613;Inherit;False;Property;_1ScrollYSpeed;1. Scroll Y Speed;1;0;Create;True;0;0;0;False;0;False;0;-0.02;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1885.07,-221.0392;Inherit;False;Property;_1ScrollXSpeed;1. Scroll X Speed;0;0;Create;True;0;0;0;False;0;False;0;0.015;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1818.951,245.9806;Inherit;False;Property;_2ScrollXSpeed;2. Scroll X Speed;3;0;Create;True;0;0;0;False;0;False;0;-0.01;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1823.698,426.5763;Inherit;False;Property;_2ScrollYSpeed;2. Scroll Y Speed;2;0;Create;True;0;0;0;False;0;False;0;-0.007;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-1708.159,169.6252;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-1802.829,-118.5005;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-1787.994,-319.4595;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1519.954,195.6674;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1514.309,381.3796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1570.866,-87.57382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1584.68,-290.4426;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1514.245,585.5406;Inherit;False;Property;_AlphaOffset;Alpha Offset;5;0;Create;True;0;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-1311.595,262.5732;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1388.272,76.20385;Inherit;False;Property;_AngleSpeed;Angle Speed;4;0;Create;True;0;0;0;False;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-1376.124,-109.6189;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1205.651,-154.8172;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-1126.574,215.3842;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;38;-1045.072,2.103946;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;-1503.89,660.0563;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VoronoiNode;33;-736.9728,-216.2965;Inherit;True;0;1;1;3;2;False;4;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;15.7;False;2;FLOAT;11.22;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.GradientNode;20;-1139.509,618.316;Inherit;False;0;2;2;1,1,1,0;0,0,0,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-1513.298,803.9856;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;136.7,0.08;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientNode;51;-1138.024,1079.685;Inherit;False;0;4;2;0,0,0,0;1,1,1,0.1000076;1,1,1,0.9000076;0,0,0,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.VoronoiNode;34;-759.0718,107.4037;Inherit;True;0;1;1;3;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;15.7;False;2;FLOAT;11.22;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;55;-687.736,595.1179;Inherit;False;Property;_NoiseAlphaInfluence;Noise Alpha Influence;7;0;Create;True;0;0;0;False;0;False;2;0.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;21;-1146.233,695.788;Inherit;True;2;0;OBJECT;;False;1;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-403.529,327.5415;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;53;-1149.94,886.6647;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-705.2416,776.1069;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-74.27238,75.02161;Inherit;False;Property;_Emissive;Emissive;6;0;Create;True;0;0;0;False;0;False;0;10.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-648.6559,668.2639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-445.6524,749.4626;Inherit;True;2;2;0;FLOAT;1;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-66.8714,163.6023;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.34;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;183.4891,-35.06161;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Water Caustic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.07;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;0;27;0
WireConnection;30;1;28;0
WireConnection;29;0;25;0
WireConnection;29;1;26;0
WireConnection;14;0;13;0
WireConnection;14;1;16;0
WireConnection;8;0;6;0
WireConnection;8;1;17;0
WireConnection;31;0;30;0
WireConnection;31;1;29;0
WireConnection;15;0;8;0
WireConnection;15;1;14;0
WireConnection;5;1;15;0
WireConnection;32;1;31;0
WireConnection;38;0;39;0
WireConnection;43;1;42;0
WireConnection;33;0;5;0
WireConnection;33;1;38;0
WireConnection;22;1;43;0
WireConnection;34;0;32;0
WireConnection;34;1;38;0
WireConnection;21;0;20;0
WireConnection;21;1;22;2
WireConnection;24;0;33;0
WireConnection;24;1;34;0
WireConnection;53;0;51;0
WireConnection;53;1;22;1
WireConnection;52;0;21;0
WireConnection;52;1;53;0
WireConnection;54;0;24;0
WireConnection;54;1;55;0
WireConnection;35;0;54;0
WireConnection;35;1;52;0
WireConnection;44;0;24;0
WireConnection;44;1;45;0
WireConnection;2;2;44;0
WireConnection;2;9;35;0
ASEEND*/
//CHKSM=D311727C59A86D327D1A382101F0CECC2AD3EAE0