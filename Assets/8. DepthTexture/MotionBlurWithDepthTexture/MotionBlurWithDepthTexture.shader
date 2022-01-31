// Motion Blur With Depth Texture

Shader "ShaderNotes/PostProcess/MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("Blur Size", float) = 1.0
    }
    SubShader
    {
        CGINCLUDE

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMotrix;
        float _BlurSize;

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

        };


        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            o.uv_depth = v.uv;
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0) {
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif

            return o;
        }

        fixed4 frag(v2f i) : SV_Target {
            // Get the depth buffer value at this pixel
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            // H is the viewport position at this pixel in the range -1 to 1
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
            // Transform by the view-projection inverse.
            float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
            // Divide vy w to get the world position
            float4 worldPos = D / D.w;

            // Current viewport position
            float4 currentPos = H;
            // Use the world position, and transform by the previous view-projection matrix
            float4 previousPos = mul(_PreviousViewProjectionMotrix, worldPos);
            // Convert to nonhomogeneous points [-1, 1] by dividing by w.
            previousPos /= previousPos.w;

            // Use this frame's position and last frame's to compute the pixel velocity
            float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;
            float2 uv = i.uv;
            float4 c = tex2D(_MainTex, uv);
            uv += velocity * _BlurSize;
            for(int it = 1; it < 3; it++, uv += velocity * _BlurSize) {
                float4 currentColor = tex2D(_MainTex, uv);
                c += currentColor;
            }

            c /= 3;

            return fixed4(c.rgb, 1.0f);
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
