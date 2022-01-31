// Phong Mode


Shader "ShaderNotes/Texture/SingleTexture"
{
   Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
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

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);
                // Transform the normal from object space to world space 
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // Transform the vertex from object space to world space
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                // get the uv
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // or using the built-in function 
                // o.uv =  TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // normalize the world normal 
                fixed3 worldNormal = normalize(i.worldNormal);
                // Get the light direction in world space
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                // Use the texture to sample the diffuse color
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse;
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // compute diffuse term 
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                // Get the view direction in world space
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                // get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                float3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }


            ENDCG
         }
    }
            Fallback "Specular"

}
