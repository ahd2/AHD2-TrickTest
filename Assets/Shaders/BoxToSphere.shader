Shader "CustomShader/BoxToSphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SphereCol("SphereCol", Color) = (0, 0, 0, 1)
        _Param("偏移系数", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float4 positionWS : TEXCOORD1;
                float3 normalWS  : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _PlayerPos;
            //half4 _SphereCol;
            half _Param;
            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
            UNITY_DEFINE_INSTANCED_PROP(half4, _SphereCol)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
            
            half SphereSDF(float3 pos)
            {
                half radius = frac(_Time.y * 0.3) * 15;
                return length(pos) - radius;//默认为球心在原点
            }

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                half radius = 1.73205080756888;//半径根号3
                half v2oDistance = length(v.positionOS.xyz);//顶点到原点距离
                half3 vDir = normalize(v.positionOS.xyz);//顶点的方向向量

                float3 originalWS = TransformObjectToWorld(float3(0, 0, 0));//原点的世界坐标
                //half sdf = SphereSDF(originalWS);//只有球体
                half sdf = length(originalWS - _PlayerPos) * 0.2;//只有玩家
                //half sdf = min(SphereSDF(originalWS), length(originalWS - _PlayerPos) * 0.2);//加上玩家
                sdf = 1 - saturate(abs(sdf) -0.3);
                v.positionOS.xyz += (radius - v2oDistance) * vDir * _Param * sdf;//顶点偏移  没够的距离乘以方向
                o.positionCS = TransformObjectToHClip(v.positionOS);
                v.normalOS = lerp(v.normalOS, vDir, _Param * sdf);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);//向量记得在片元归一化
                o.positionWS.xyz = TransformObjectToWorld(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.positionWS.a = sdf;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                i.normalWS = normalize(i.normalWS);
                half4 col = tex2D(_MainTex, i.uv) * 1.5;
                half NoL = max(0, dot(i.normalWS, _MainLightPosition));
                half halflambert = (NoL * 0.5 + 0.5) * (NoL * 0.5 + 0.5);
                col = lerp(col, UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SphereCol), _Param * i.positionWS.a);
                return col * halflambert;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}