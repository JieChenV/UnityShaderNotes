using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProcedualTextureGenerate : MonoBehaviour
{
    public Material material = null;

    #region Material properties
    [SerializeField]
    private int m_textureWidth = 512;
    public int textureWidth {
        get
        {
            return m_textureWidth;
        }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField]
    private float m_blurFactor = 2.0f;
    public float blurFactor
    {
        get
        {
            return m_blurFactor;
        }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTexture = null;
    // Start is called before the first frame update
    void Start()
    {
        if(material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer == null)
            {
                Debug.Log("Cannot find a renderer.");
                return;
            }

            material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void _UpdateMaterial() {
        if(material != null)
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        // define the distance between circles
        float circleInterval = textureWidth / 4.0f;

        // define the radius of the circle
        float radius = textureWidth / 10.0f;

        float edgeBlur = 1.0f / blurFactor;

        for(int w=0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                // using the background color for initializing the texture
                Color pixel = backgroundColor;

                // draw 9 circle
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));

                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        Color color = Color.Lerp(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0, 1.0f, dist * edgeBlur));
                        pixel = Color.Lerp(pixel, color, color.a);
                    }
                }

                proceduralTexture.SetPixel(w, h, pixel);
            }
        }

        proceduralTexture.Apply();

        return proceduralTexture;
    }

}
