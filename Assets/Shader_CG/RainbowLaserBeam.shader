﻿Shader "Custom/RainbowLaserBeam" {
    Properties{
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
        speed("speed",range(0,1))=0.1
    }

    CGINCLUDE    
    	float speed;
        #include "UnityCG.cginc"   
        #pragma target 3.0      

        #define vec2 float2
        #define vec3 float3
        #define vec4 float4
        #define mat2 float2x2
        #define iGlobalTime _Time.y*speed
        #define mod fmod
        #define mix lerp
        #define atan atan2
        #define fract frac 
        #define texture2D tex2D
        // 屏幕的尺寸
        #define iResolution _ScreenParams
        // 屏幕中的坐标，以pixel为单位
        #define gl_FragCoord ((_iParam.srcPos.xy/_iParam.srcPos.w)*_ScreenParams.xy) 

        #define PI2 6.28318530718
        #define pi 3.14159265358979
        #define halfpi (pi * 0.5)
        #define oneoverpi (1.0 / pi)

        fixed4 iMouse;
        sampler2D iChannel0;
        fixed4 iChannelResolution0;

        struct v2f {    
            float4 pos : SV_POSITION;    
            float4 srcPos : TEXCOORD0;   
        };              

        v2f vert(appdata_base v) {  
            v2f o;
            o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
            o.srcPos = ComputeScreenPos(o.pos);  
            return o;    
        }  
        vec3 Strand(in vec2 fragCoord, in vec3 color, in float hoffset, in float hscale, in float vscale, in float timescale)
		{
		    float glow = 0.06 * iResolution.y;
		    float twopi = 6.28318530718;
		    float curve = 1.0 - abs(fragCoord.y - (sin(mod(fragCoord.x * hscale / 100.0 / iResolution.x * 1000.0 + iGlobalTime * timescale + hoffset, twopi)) * iResolution.y * 0.25 * vscale + iResolution.y / 2.0));
		    float i = clamp(curve, 0.0, 1.0);
		    i += clamp((glow + curve) / glow, 0.0, 1.0) * 0.4 ;
		    return i * color;
		}
		
		vec3 Muzzle(in vec2 fragCoord, in float timescale)
		{
		    float theta = atan(iResolution.y / 2.0 - fragCoord.y, iResolution.x - fragCoord.x + 0.13 * iResolution.x);
			float len = iResolution.y * (10.0 + sin(theta * 20.0 + float(int(iGlobalTime * 20.0)) * -35.0)) / 11.0;
		    float d = max(-0.6, 1.0 - (sqrt(pow(abs(iResolution.x - fragCoord.x), 2.0) + pow(abs(iResolution.y / 2.0 - ((fragCoord.y - iResolution.y / 2.0) * 4.0 + iResolution.y / 2.0)), 2.0)) / len));
		    return vec3(d * (1.0 + sin(theta * 10.0 + floor(iGlobalTime * 20.0) * 10.77) * 0.5), d * (1.0 + -cos(theta * 8.0 - floor(iGlobalTime * 20.0) * 8.77) * 0.5), d * (1.0 + -sin(theta * 6.0 - floor(iGlobalTime * 20.0) * 134.77) * 0.5));
		}
		fixed4 mainImage(in vec2 fragCoord )
		{
		    float timescale = 4.0;
			vec3 c = vec3(0, 0, 0);
		    c += Strand(fragCoord, vec3(1.0, 0, 0), 0.7934 + 1.0 + sin(iGlobalTime) * 30.0, 1.0, 0.16, 10.0 * timescale);
		    c += Strand(fragCoord, vec3(0.0, 1.0, 0.0), 0.645 + 1.0 + sin(iGlobalTime) * 30.0, 1.5, 0.2, 10.3 * timescale);
		    c += Strand(fragCoord, vec3(0.0, 0.0, 1.0), 0.735 + 1.0 + sin(iGlobalTime) * 30.0, 1.3, 0.19, 8.0 * timescale);
		    c += Strand(fragCoord, vec3(1.0, 1.0, 0.0), 0.9245 + 1.0 + sin(iGlobalTime) * 30.0, 1.6, 0.14, 12.0 * timescale);
		    c += Strand(fragCoord, vec3(0.0, 1.0, 1.0), 0.7234 + 1.0 + sin(iGlobalTime) * 30.0, 1.9, 0.23, 14.0 * timescale);
		    c += Strand(fragCoord, vec3(1.0, 0.0, 1.0), 0.84525 + 1.0 + sin(iGlobalTime) * 30.0, 1.2, 0.18, 9.0 * timescale);
		    c += clamp(Muzzle(fragCoord, timescale), 0.0, 1.0);
			return vec4(c.r, c.g, c.b, 1.0);
		}
		
        fixed4 frag(v2f _iParam) : COLOR0 { 
            vec2 fragCoord = gl_FragCoord;
            return mainImage(gl_FragCoord);
        }  


    ENDCG    

    SubShader {    
        Pass {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        }    
    }     
    FallBack Off    
}

