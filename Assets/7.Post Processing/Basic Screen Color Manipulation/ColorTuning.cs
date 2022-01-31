using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorTuning : PostProcessBase
{
    public Shader ColorTuningShader;
    private Material colorTuningMat;
    public Material Mat
    {
        get
        {
            colorTuningMat = CheckShaderAndCreateMaterial(ColorTuningShader, colorTuningMat);
            return colorTuningMat;
        }
    }

    [Range(0.0f, 3.0f)]
    public float Brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float Saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float Contrast = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mat != null)
        {
            Mat.SetFloat("_Brightness", Brightness);
            Mat.SetFloat("_Saturation", Saturation);
            Mat.SetFloat("_Contrast", Contrast);

            Graphics.Blit(source, destination, Mat);
        }else
        {
            Graphics.Blit(source, destination);
        }
    }

}
