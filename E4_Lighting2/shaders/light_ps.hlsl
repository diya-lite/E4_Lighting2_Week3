// Light pixel shader
// Calculate diffuse lighting for a single directional light (also texturing)

Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

cbuffer LightBuffer : register(b0)
{
	float4 ambient[2];
    float4 diffuse[2];
    float4 position[2];
    float4 specular;
	
};

struct InputType
{
	float4 position : SV_POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	float3 worldPosition : TEXCOORD1;
    float3 viewVector : TEXCOORD2;
};

//
float4 calcSpecular(float3 lightDirection, float3 normal, float3 viewVector, float4 specularColour, float specularPower)
{
// blinn-phong specular calculation
    float3 halfway = normalize(lightDirection + viewVector);
    float specularIntensity = pow(max(dot(normal, halfway), 0.0), specularPower);
    return saturate(specularColour * specularIntensity);
}
// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float3 lightDirection, float3 normal, float4 ldiffuse)
{
	float intensity = saturate(dot(normal, lightDirection));
	float4 colour = saturate(ldiffuse * intensity);
    
	return colour;
}

float4 main(InputType input) : SV_TARGET
{
	
    float specularPower=1.0f;
	// Sample the texture. Calculate light intensity and colour, return light*texture for final pixel colour.
	float4 textureColour = texture0.Sample(sampler0, input.tex);
    float4 lightColour=(0,0,0,0);
    for (int i = 0; i < 2;i++)
    {
        
        float dist = length(position[i].xyz - input.worldPosition);
        float attenuation = 1 / (0.5 + (0.125 * dist) + (0.0 * pow(dist, 2)));
        
        float3 lightVector = normalize(position[i].xyz - input.worldPosition);
        lightColour += ambient[i] + (calculateLighting(lightVector, input.normal, diffuse[i]) + calcSpecular(lightVector, input.normal, input.viewVector, specular, specularPower)) * attenuation;
       
    }
        
    return lightColour * textureColour;
	
}



