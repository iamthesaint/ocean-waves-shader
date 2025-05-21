uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;
uniform sampler2D uEnvMap;
uniform vec3 uCameraPosition;

#define PI 3.14159265359

varying vec3 vWorldPosition;
varying vec3 vNormal;
varying float vElevation;

 vec2 equirectUv(vec3 dir) {
    float u = atan(dir.z, dir.x) / (2.0 * PI) + 0.5;
    float v = asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5;
    return vec2(u, v);
    }

vec3 blurredReflection(vec2 uv)
{
    vec3 col = vec3(0.0);
    float total = 0.0;
    float blurSize = 0.09;

    for (float x = -2.0; x <= 2.0; x++) {
        for (float y = -2.0; y <= 2.0; y++) {
            float weight = 1.0 - length(vec2(x, y)) / 2.828;
            col += texture2D(uEnvMap, uv + vec2(x, y) * blurSize).rgb * weight;
            total += weight;
        }
    }

    return col / total;
}

void main ()
{
    vec3 viewDir = normalize(vWorldPosition - uCameraPosition);
    vec3 reflectDir = reflect(viewDir, normalize(vNormal));

    vec2 uv = equirectUv(reflectDir);
    vec3 reflectedColor = blurredReflection(uv); 

    vec3 waterColor = mix(uDepthColor, uSurfaceColor, (vElevation + uColorOffset) * uColorMultiplier);
    float fresnel = pow(1.0 - dot(viewDir, normalize(vNormal)), 3.0);
    vec3 finalColor = mix(waterColor, reflectedColor, fresnel);

    gl_FragColor = vec4(finalColor, 1.0);
    #include <colorspace_fragment>
}