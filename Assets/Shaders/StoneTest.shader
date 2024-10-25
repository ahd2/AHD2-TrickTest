Shader "CustomShader/StoneTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float3 normalWS  : TEXCOORD2;
                float4 posNDC : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;\

            v2f vert (appdata v)
            {
                v2f o;
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);//向量记得在片元归一化
                VertexPositionInputs position_inputs = GetVertexPositionInputs(v.positionOS);
                o.posNDC = position_inputs.positionNDC;
                o.positionCS = position_inputs.positionCS;
                o.positionWS = TransformObjectToWorld(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //屏幕uv
                half2 screenUV = i.posNDC.xy / i.posNDC.w;
                //采样深度图
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(screenUV);
                #else
                    // 调整 z 以匹配 OpenGL 的 NDC
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif
                i.normalWS = normalize(i.normalWS);
                half4 col = tex2D(_MainTex, i.uv);
                //自己的深度
                real SelfDepth = i.posNDC.z;
                return step((SelfDepth - depth), 0.1);
                return depth;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}