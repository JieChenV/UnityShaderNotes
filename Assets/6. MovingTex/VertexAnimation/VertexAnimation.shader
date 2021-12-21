// Vertex Animation Water Wave

Shader "ShaderNotes/AnimateTexture/VertexAnimation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Magnitude ("Distortion Magnitude", float) = 1.0
        _Frequency ("Distortion Frequency", float) = 1.0
        _InvWaveLength ("Distortion Inverse Wave Length", float) = 10.0
        _Speed ("Speed", float) = 0.5
    }
    SubShader
    {
        // Need to disable batching because of the vertex animation
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True" }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

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
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;

                float4 offset;
                offset.yzw = float3(0.0, 0.0,0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                o.pos = UnityObjectToClipPos(v.vertex + offset);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv += float2(0.0, _Time.y * _Speed);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D (_MainTex, i.uv.xy);

                c.rgb *= _Color.rgb;

                return c;
            }
            ENDCG
        }

        // Pass to render object as a shadow caster
        Pass {
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : TEXCOORD0;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(a2v v) {

                v2f o;
                float4 offset;
                offset.yzw = float3(0.0, 0.0,0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                v.vertex = v.vertex + offset;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

                return o;
            }

            fixed4 frag( v2f i) : SV_Target {
                SHADOW_CASTER_FRAGMENT(i)
            }

            
            ENDCG
        }
    }

    Fallback "VertexLit"
}
