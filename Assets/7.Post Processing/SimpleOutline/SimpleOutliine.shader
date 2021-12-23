// Using Sobel as the convolution kernel, the effect does not work well, come back to check out later

Shader "ShaderNotes/PostProcess/SimpleOutliine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineOnly ("Outline Only", float) = 1
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _BackgroundColor ("Background Color", Color) = (1,1,1,1) 
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // Most Post processing will have the same settings like this there lines
        ZTest Always
        Cull Off
        ZWrite Off
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            float _OutlineOnly;
            float4 _OutlineColor;
            float4  _BackgroundColor;

            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i) {
                const half Gx[9] = {-1, -2, -1,
                                    0, 0, 0,
                                    1, 2, 1 };
                const half Gy[9] = {-1, 0, 1,
                                    -2, 0, 2,
                                    -1, 0, 1 };

                half texColor;
                half outlineX = 0;
                half outlineY = 0;
                for(int it = 0; it < 9; it++) {
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));
                    outlineX += texColor * Gx[it];
                    outlineY += texColor * Gy[it];
                }

                half outline = 1 - abs(outlineX) - abs(outlineY);
                

                return outline;
            }


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half outline = Sobel(i);

                fixed4 withOutlineColor = lerp(_OutlineColor, tex2D(_MainTex, i.uv[4]), outline);
                fixed4 onlyOutlineColor = lerp(_OutlineColor, _BackgroundColor, outline);

                //return outline;
                return lerp(withOutlineColor, onlyOutlineColor, _OutlineOnly);
            }
            ENDCG
        }
    }
    Fallback off
}
