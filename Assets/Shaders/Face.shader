Shader "Unlit/Face"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaxDistance ("MaxDistance ", Float) = 5.0
        _FaceColor("FaceColor", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        ZTest Off
        Tags { "Queue" = "AlphaTest" "RenderType"="AlphaTest" }
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
                float4 uv : TEXCOORD0;//zw通道存方向
                float4 positionCS : SV_POSITION;
                float4 positionWS : TEXCOORD1;//a通道存光源到原点距离
                float3 normalWS  : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float3 _SpherePosition;
            half4 _FaceColor;
            float _MaxDistance;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);//向量记得在片元归一化
                o.positionWS.xyz = TransformObjectToWorld(v.positionOS.xyz);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                float3 originalPos = TransformObjectToWorld(float3(0, 0, 0));
                o.positionWS.a = distance(originalPos, _SpherePosition);
                o.positionWS.a = 1 - saturate(o.positionWS.a / _MaxDistance);//但是永远无法到达最近，所以distance永远无法为1，而且会有一段距离
                o.uv.zw = normalize(_SpherePosition - originalPos).xz;//世界空间坐标方向
                return o;
            }

            float testCross(float2 a, float2 b, float2 p)
            {
                return sign((b.y-a.y) * (p.x-a.x) - (b.x-a.x) * (p.y-a.y));
            }

            float signBezier(float2 A, float2 B, float2 C, float2 p)
            { 
                float2 a = C - A, b = B - A, c = p - A;
                float2 bary = float2(c.x*b.y-b.x*c.y,a.x*c.y-c.x*a.y) / (a.x*b.y-b.x*a.y);
                float2 d = float2(bary.y * 0.5, 0.0) + 1.0 - bary.x - bary.y;
                return lerp(sign(d.x * d.x - d.y), lerp(-1.0, 1.0, 
                    step(testCross(A, B, p) * testCross(B, C, p), 0.0)),
                    step((d.x - d.y), 0.0)) * testCross(A, C, B);
            }

            float3 solveCubic(float a, float b, float c)
            {
                float p = b - a*a / 3.0, p3 = p*p*p;
                float q = a * (2.0*a*a - 9.0*b) / 27.0 + c;
                float d = q*q + 4.0*p3 / 27.0;
                float offset = -a / 3.0;
                if(d >= 0.0) { 
                    float z = sqrt(d);
                    float2 x = (float2(z, -z) - q) / 2.0;
                    float2 uv = sign(x)*pow(abs(x), float2(1.0/3.0, 1.0/3.0));
                    return float3(offset + uv.x + uv.y, offset + uv.x + uv.y, offset + uv.x + uv.y);
                }
                float v = acos(-sqrt(-27.0 / p3) * q / 2.0) / 3.0;
                float m = cos(v), n = sin(v)*1.732050808;
                return float3(m + m, -n - m, n - m) * sqrt(-p / 3.0) + offset;
            }

            float sdBezier(float2 A, float2 B, float2 C, float2 p)
            {    
                B = lerp(B + float2(0.0001,0.0001), B, abs(sign(B * 2.0 - A - C)));
                float2 a = B - A, b = A - B * 2.0 + C, c = a * 2.0, d = A - p;
                float3 k = float3(3.*dot(a,b),2.*dot(a,a)+dot(d,b),dot(d,a)) / dot(b,b);      
                float3 t = clamp(solveCubic(k.x, k.y, k.z), 0.0, 1.0);
                float2 pos = A + (c + b*t.x)*t.x;
                float dis = length(pos - p);
                pos = A + (c + b*t.y)*t.y;
                dis = min(dis, length(pos - p));
                pos = A + (c + b*t.z)*t.z;
                dis = min(dis, length(pos - p));
                return dis * signBezier(A, B, C, p);
            }

            half4 frag (v2f i) : SV_Target
            {
                i.normalWS = normalize(i.normalWS);
                float dis = i.positionWS.a;
                
                //左边眼睛
                float2 ALeft = float2(0.2, 0.6), BLeft = float2(0.3, 0.7 - 0.25 * dis), CLeft = float2(0.4, 0.6);
                float dLeft = abs(sdBezier(ALeft, BLeft, CLeft, i.uv));

                //右边眼睛
                float2 ARight = float2(0.6, 0.6), BRight = float2(0.7, 0.7 - 0.25 * dis), CRight = float2(0.8, 0.6);
                float dRight = abs(sdBezier(ARight, BRight, CRight, i.uv));

                //嘴巴
                float2 AMouth = float2(0.42, 0.3), BMouth = float2(0.5, 0.22 + 0.2 * dis), CMouth = float2(0.58, 0.3);
                float dMouth = abs(sdBezier(AMouth, BMouth, CMouth, i.uv)) * 2;
                
                float dEyes = min(dLeft, dRight);//先都取绝对值再取最小值
                float d = min(dEyes, dMouth);//先都取绝对值再取最小值
                d = smoothstep(0, 0.15, d);

                dEyes = step(dEyes, 0.04 * dis);
                //眼睛瞳孔(不能直接用Bleft这种，因为他们有位移了
                float EyesCore = min(distance(i.uv, float2(0.3, 0.6) - (0.03 * i.uv.zw * dis)), distance(i.uv, float2(0.7, 0.6) - (0.03 * i.uv.zw * dis)));
                EyesCore = step(0.06, EyesCore);
                
                clip(0.3 - d);
                //return EyesCore;
                //return EyesCore;
                //return dEyes;
                return lerp(_FaceColor, EyesCore, dEyes);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}
