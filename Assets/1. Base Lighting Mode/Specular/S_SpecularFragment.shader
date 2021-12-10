// Phong Mode


Shader "ShaderNotes/LightMode/S_SpecularFragment"
{
   Properties
    {
       _Diffuse ("Diffuse", Color) = (1,1,1,1)
       _Specular ("Specular", Color) = (1,1,1,1)
       _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "LightingMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);
                // Transform the normal from object space to world space 
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                // Transform the vertex from object space to world space
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // normalize the world normal 
                fixed3 worldNormal = normalize(i.worldNormal);
                // Get the light direction in world space
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                // Get the reflect direction in world space
                fixed3 reflectDir = normalize(reflect(_WorldSpaceCameraPos.xyz, i.worldNormal.xyz));
                // Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                float3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }


            ENDCG
         }
    }
            Fallback "Specular"

}
