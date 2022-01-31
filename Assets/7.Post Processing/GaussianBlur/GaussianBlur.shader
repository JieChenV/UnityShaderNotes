// Gaussian Blur

Shader "ShaderNotes/PostProcess/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurSize;
            half4 _Maintex_TexelSize;

            v2f vertBlurVertical (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;

                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _Maintex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0.0, _Maintex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0.0, _Maintex_TexelSize.y * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _Maintex_TexelSize.y * 2.0) * _BlurSize;

                return o;
            }

            v2f vertBlurHorizontal (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;

                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _Maintex_TexelSize.x * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0.0, _Maintex_TexelSize.x * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0.0, _Maintex_TexelSize.x * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _Maintex_TexelSize.x * 2.0) * _BlurSize;

                return o;
            }

            fixed4 fragBlur(v2f i) : SV_Target {

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

        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }

        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG
        }
    }

    Fallback Off
}
