// Lambert Mode

Shader "ShaderNotes/LightMode/BaseVertex"
{
    Properties
    {
       _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightingMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // Transform the normal from object space to world space
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // Get the light direction in world space
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                o.color = ambient + diffuse;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                return fixed4(i.color, 1.0);
            }


            ENDCG


        }

        
    }

            Fallback "Diffuse"

}
