Shader "ShaderNotes/PostProcess/ColorTuningShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("Brightness", float) = 1
        _Saturation ("Saturation", float) = 1
        _Contrast("Contrast", float) = 1
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Saturation;
            float _Contrast;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 finalColor = col.rgb * _Brightness;
                // Apply brightness
                fixed luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);

                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                // Apply contrast
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, col.a);
            }
            ENDCG
        }
    }
    Fallback Off
}
