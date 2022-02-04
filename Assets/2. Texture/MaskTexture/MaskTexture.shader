// mask texture


Shader "ShaderNotes/Texture/MaskTexture"
{
   Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", float) = 1.0
        _SpecularMask("Specular Mask", 2D ) = "white" {}
        _SpecularScale ("Specular Scale", float) = 1.0
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
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _SpecularMask;
            fixed4 _SpecularMask_ST;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                // get the main texture's uv
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                // compute the binormal
                //float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
                // construct a matrix which transform vectors from object space to tangent space
                //float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                // or just use the built-in macro
                TANGENT_SPACE_ROTATION;

                // transform the light direction from object space to the tangent space
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                // transform the view direction from object space to the tangent space
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                // get the texel in the normal map
                fixed4 packedNormal = tex2D(_BumpMap, i.uv);
                fixed3 tangentNormal;

                // if the texture is not marked as "Normal map"
                // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                // tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // or mark the texture as "Normal map" and use the built-in function
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

               
                // Use the texture to sample the diffuse color 
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // compute diffuse term 
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentViewDir));
                // get the half direction in world space
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                // Get the mask value 
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                // compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;

                float3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }
            ENDCG
         }
    }
    Fallback "Specular"

}
