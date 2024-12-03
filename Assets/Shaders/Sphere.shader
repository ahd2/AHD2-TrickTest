Shader "Unlit/Sphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaxDistance ("MaxDistance ", Float) = 5.0
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
                float4 positionWS : TEXCOORD1;//a通道存光源到原点距离
                float3 normalWS  : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float3 _SpherePosition;
            float _MaxDistance;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);//向量记得在片元归一化
                o.positionWS.xyz = TransformObjectToWorld(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 originalPos = TransformObjectToWorld(float3(0, 0, 0));
                o.positionWS.a = distance(originalPos, _SpherePosition);
                o.positionWS.a = 1 - saturate(o.positionWS.a / _MaxDistance);//但是永远无法到达最近，所以distance永远无法为1，而且会有一段距离
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                i.normalWS = normalize(i.normalWS);
                Light pointLight = GetAdditionalLight(0, i.positionWS);//只拿唯一一个点光源
                half halflambert = dot(i.normalWS, pointLight.direction) * 0.5 + 0.5;
                halflambert *= halflambert;
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(halflambert, 0.5));
                //边缘光
                half3 viewDirWS = normalize(normalize(GetWorldSpaceViewDir(i.positionWS)) - float3(pointLight.direction.x, 0, pointLight.direction.z));
                //viewDirWS -= pointLight.direction;
                half NoV = saturate(pow(1 - dot(viewDirWS, i.normalWS), 5));
                half3 rimCol = NoV * pointLight.color;
                col.xyz += rimCol * i.positionWS.a;//边缘光衰减
                return col;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"//不考虑合批，先直接借用了
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}
