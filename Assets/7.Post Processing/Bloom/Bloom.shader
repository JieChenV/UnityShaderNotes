// Gaussian Blur

Shader "ShaderNotes/PostProcess/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bloom ("Bloom (RGB)", 2D) = "black" {}
        _LuminanceThreshold ("Luminance Threshold", float) = 0.5
        _BlurSize ("Blur Size", float) = 1.0
    }
    SubShader
    {

        CGINCLUDE

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct appdata_img
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            struct v2fBlur
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bloom;
            float _LuminanceThreshold;
            float _BlurSize;
            half4 _Maintex_TexelSize;

            v2f vertExtractBright (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            fixed4 fragExtractBright(v2f i) : SV_Target {
                fixed4 c = tex2D(_MainTex, i.uv);
                fixed val = clamp(luminance(c) - _LuminanceThreshold, 0.0, 1.0);

                return c * val;
            }

            struct v2fBloom {
                float4 vertex : SV_POSITION;
                half4 uv :  TEXCOORD0;
            };

            v2fBloom vertBloom(appdata_img v) {
                v2fBloom o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                o.uv.zw = v.uv;

                #if UNITY_UVSTARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0.0) {
                    o.uv.w = 1.0 - o.uv.w;
                }
                #endif

                return o;
            }

            fixed4 fragBloom(v2fBloom i) : SV_Target {
                return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
            }

            v2fBlur vertBlurVertical (appdata v)
            {
                v2fBlur o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;

                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _Maintex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0.0, _Maintex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0.0, _Maintex_TexelSize.y * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _Maintex_TexelSize.y * 2.0) * _BlurSize;

                return o;
            }

            v2fBlur vertBlurHorizontal (appdata v)
            {
                v2fBlur o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;

                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _Maintex_TexelSize.x * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0.0, _Maintex_TexelSize.x * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0.0, _Maintex_TexelSize.x * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _Maintex_TexelSize.x * 2.0) * _BlurSize;

                return o;
            }

            fixed4 fragBlur(v2fBlur i) : SV_Target {

                float weight[3] = {0.4026, 0.2442, 0.0545};

                fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
                for(int it  =1; it < 3; it++) {
                    sum += tex2D(_MainTex, i.uv[it]).rgb * weight[it];
                    sum += tex2D(_MainTex, i.uv[2*it]).rgb * weight[it];
                }

                return fixed4(sum, 1.0);
            }
        ENDCG

        Tags { "RenderType"="Opaque" }

            // Most Post processing will have the same settings like this there lines
            ZTest Always
            Cull Off
            ZWrite Off

        Pass {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright

            ENDCG
        }
        // this pass can also be used like this:
        // UsePass "Path/to/the/GAUSSIAN_BLUR_VERTICAL"
        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }
        // this pass can also be used like this:
        // UsePass "Path/to/the/GAUSSIAN_BLUR_HORIZONTAL"
        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG
        }

        Pass {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom

            ENDCG
        }
    }

    Fallback Off
}
