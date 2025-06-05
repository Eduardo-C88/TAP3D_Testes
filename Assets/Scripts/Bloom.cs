using UnityEngine;

[ExecuteInEditMode]
public class Bloom : MonoBehaviour
{
    public Shader bloomShader;
    public float intensity = 1.0f;
    public float threshold = 0.7f;
    public float blurSize = 1.0f;
    public Color bloomColor = new Color(1, 0.9f, 0.7f); // Amarelo claro/quente
    public float colorIntensity = 1.0f;
    
    private Material bloomMaterial;
    private RenderTexture[] renderTextures = new RenderTexture[2];

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (bloomShader == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if (bloomMaterial == null)
        {
            bloomMaterial = new Material(bloomShader);
            bloomMaterial.hideFlags = HideFlags.HideAndDontSave;
        }

        bloomMaterial.SetFloat("_Intensity", intensity);
        bloomMaterial.SetFloat("_Threshold", threshold);
        bloomMaterial.SetFloat("_BlurSize", blurSize);
        bloomMaterial.SetColor("_BloomColor", bloomColor);
        bloomMaterial.SetFloat("_ColorIntensity", colorIntensity);

        // Criar RT temporários
        int width = source.width / 2;
        int height = source.height / 2;
        RenderTexture rt0 = RenderTexture.GetTemporary(width, height, 0, source.format);
        RenderTexture rt1 = RenderTexture.GetTemporary(width, height, 0, source.format);

        // Passo 1: Extrair áreas brilhantes com cor amarelada
        Graphics.Blit(source, rt0, bloomMaterial, 0);

        // Passo 2: Borrar horizontalmente
        Graphics.Blit(rt0, rt1, bloomMaterial, 1);

        // Passo 3: Borrar verticalmente
        Graphics.Blit(rt1, rt0, bloomMaterial, 2);

        // Passo 4: Combinar
        bloomMaterial.SetTexture("_BloomTex", rt0);
        Graphics.Blit(source, destination, bloomMaterial, 3);

        // Liberar RT temporários
        RenderTexture.ReleaseTemporary(rt0);
        RenderTexture.ReleaseTemporary(rt1);
    }
}