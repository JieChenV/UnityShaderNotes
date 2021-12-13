// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// AlphaTest


Shader "ShaderNotes/Transparent/AlphaTest"
{
   Properties
    {
        _Diffuse ("Main Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }

        Pass
        {
            Tags { "LightMode"="ForwardBase"}

            // both sides, turn off culling
            // Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // compute diffuse term
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Alpha test
                clip(texColor.a - _Cutoff);

                fixed3 albedo = texColor.rgb * _Diffuse.rgb;
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                fixed viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                float3 color = ambient + diffuse;

                return fixed4(color, 1.0);
            }


            ENDCG
         }
    }
            Fallback "Transparent/Cutout/VertexLit"

}
