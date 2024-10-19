Shader "CustomShader/BoxToSphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Param("偏移系数", Range(0, 1)) = 0.0
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
                float3 positionWS : TEXCOORD1;
                float3 normalWS  : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Param;

            v2f vert (appdata v)
            {
                v2f o;
                half radius = 1.73205080756888;//半径根号3
                half v2oDistance = length(v.positionOS.xyz);//顶点到原点距离
                half3 vDir = normalize(v.positionOS.xyz);//顶点的方向向量
                v.positionOS.xyz += (radius - v2oDistance) * vDir * _Param;//顶点偏移  没够的距离乘以方向
                o.positionCS = TransformObjectToHClip(v.positionOS);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);//向量记得在片元归一化
                o.positionWS = TransformObjectToWorld(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                i.normalWS = normalize(i.normalWS);
                half4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}