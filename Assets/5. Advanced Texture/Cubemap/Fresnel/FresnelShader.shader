// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderNotes/AdvancedTex/FresnelShader"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1,1,1,1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal: TEXCPPRD0;
                float3 worldPos : TEXCOORD1;
                float3 worldRefl : TEXCOORD2;
                float3 worldViewDir : TEXCOORD3;

                // 4 stands for the next available TEXCOORD number 
                SHADOW_COORDS(4) 
            };

            float4 _Color;
            fixed _FresnelScale;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                // compute the reflect dir in world space
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // normalize the world normal 
                fixed3 worldNormal = normalize(i.worldNormal);
                // normalize the world view direction
                fixed3 worldViewDir = normalize(i.worldViewDir);
                // Get the light direction in world space
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
                // Use the reflect dir in world space to access the cubemap 
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;

                //compute the fresnel
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

                // UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                float3 color = ambient + lerp(diffuse , reflection, saturate(fresnel)) * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
