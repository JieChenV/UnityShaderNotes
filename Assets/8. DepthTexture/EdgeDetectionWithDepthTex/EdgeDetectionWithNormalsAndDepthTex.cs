using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectionWithNormalsAndDepthTex : PostProcessBase
{
    public Shader EdgeShader;
    private Material _edgeMat = null;
    public Material material
    {
        get
        {
            _edgeMat = CheckShaderAndCreateMaterial(EdgeShader, _edgeMat);
            return _edgeMat;
        }
    }

    [Range(0.0f, 1.0f)]
    public float edgeOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1.0f;
    public float sensitiveityDepth = 1.0f;
    public float sensitivityNormals = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitiveityDepth, 0.0f, 0.0f));

            Graphics.Blit(source, destination, material);
        }
        else {
            Debug.Log("material is null");
            Graphics.Blit(source, destination);
        }

    }
}
