// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderNotes/AdvancedTex/GlassShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _RefractAmount ("Refraction Amount", Range(0, 1)) = 1
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
        _Distortion ("Distortion", Range(0, 100)) = 10
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }

        GrabPass { "_RefractionTex" }

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
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                float4 srcPos : TEXCOORD4;
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _RefractAmount;
            float _Distortion;
            samplerCUBE _Cubemap;

            // used for the grab pass
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                
                o.srcPos = ComputeGrabScreenPos(o.pos);

                // get the main texture's uv
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // get the normal texuture's uv
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                // compute the matrix that transform direction from tangent space to world space
                // Put the world position in w component for optimization
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                // get the position in world space
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // Get the normal in tangent space
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                // compute the offset in tangent space
                float2 offset =  bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.srcPos.xy = offset + i.srcPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.srcPos.xy / i.srcPos.w).rgb;

                // transform the normal from tangent space to world space
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                fixed3 reflDir = reflect(-worldViewDir, bump);
                // Use the texture to sample the diffuse color
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * albedo.rgb;

                float3 color = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
