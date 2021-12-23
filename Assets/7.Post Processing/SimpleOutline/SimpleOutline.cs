using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleOutline : PostProcessBase
{
    public Shader OutlineShader;
    private Material _outlineMat = null;
    public Material OutlineMat {
        get
        {
            _outlineMat = CheckShaderAndCreateMaterial(OutlineShader, _outlineMat);
            return _outlineMat;
        }
    }

    [Range(0.0f, 1.0f)]
    public float OutlineOnly = 0.0f;
    public Color OutlineColor = Color.black;
    public Color BackgroundColor = Color.black;


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (OutlineMat != null)
        {
            OutlineMat.SetFloat("_OutlineOnly", OutlineOnly);
            OutlineMat.SetColor("_OutlineColor", OutlineColor);
            OutlineMat.SetColor("_BackgroundColor", BackgroundColor);

            Graphics.Blit(source, destination, OutlineMat);
        }else
        {
            Graphics.Blit(source, destination);
        }
    }
}
