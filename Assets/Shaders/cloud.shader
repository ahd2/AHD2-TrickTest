Shader "CustomShader/cloud"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaTex("AlphaTex", 2D) = "" { }
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
                float4 tangentOS  : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float4 positionWS : TEXCOORD1;
                float3 normalWS  : TEXCOORD2;
                half3 tangentWS  : TEXCOORD3;
                half3 bitangentWS : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AlphaTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
                o.normalWS = normalInput.normalWS;
                o.tangentWS = normalInput.tangentWS;
                o.bitangentWS = normalInput.bitangentWS;
                o.positionWS.xyz = TransformObjectToWorld(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                i.normalWS = normalize(i.normalWS);
                half3 normalMap = normalize(UnpackNormal(tex2D(_MainTex, i.uv)));
                half3x3 TBN = half3x3(normalize(i.tangentWS.xyz), normalize(i.bitangentWS.xyz), i.normalWS.xyz);
                i.normalWS = TransformTangentToWorld(normalMap,TBN);//矫正了normalWS插值造成的误差，后面直接赋值即可
                //half4 col = tex2D(_MainTex, i.uv) * 1.5;
                half NoL = max(0, dot(i.normalWS, _MainLightPosition));
                half halflambert = (NoL * 0.5 + 0.5) * (NoL * 0.5 + 0.5);
                return NoL;
                return half4(i.normalWS,1);
                return half4(normalMap,1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}