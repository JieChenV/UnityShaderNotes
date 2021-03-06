// Fog With Depth Texture

Shader "ShaderNotes/PostProcess/FogWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity ("Fog Density", float) = 1.0
        _FogColor ("Fog Color", Color) = (1,1,1,1)
        _FogStart ("Fog Start", float) = 0.0
        _FogEnd("Fog End", float) = 1.0
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        float4x4 _FrustumCornersRay;

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            float2 uv_depth : TEXCOORD1;
            float4 interpolatedRay : TEXCOORD2;
        };



        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            o.uv_depth = o.uv;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0) {
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif

            int index = 0;

            if (v.uv.x < 0.5 && v.uv.y < 0.5) {
                index = 0;
            }else if (v.uv.x > 0.5 && v.uv.y < 0.5) {
                index = 1;
            }else if (v.uv.x > 0.5 && v.uv.y > 0.5) {
                index = 2;
            }else {
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0) {
                index = 3 - index;
            }
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];

            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 finalColor = tex2D(_MainTex, i.uv);
            finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

            return finalColor;
        }

        ENDCG

        Tags { "RenderType"="Opaque" }

        // Most Post processing will have the same settings like this there lines
        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            ENDCG
        }
    }

    Fallback Off
}
