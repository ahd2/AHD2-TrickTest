using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOnMesh : MonoBehaviour
{
    public RenderTexture Rt1;
    public RenderTexture Rt2;
    public Camera Cam;
    private Ray _rayMouse;//相机指向鼠标点的射线
    private Vector2 _hitUV = Vector2.zero;
    public Material CalTemperatureMat;//补个判空才对
    private static readonly int HitUV = Shader.PropertyToID("_HitUV");

    void Start()
    {
        Graphics.Blit(Texture2D.blackTexture, Rt1);
        Graphics.Blit(Texture2D.blackTexture, Rt2);
    }

    void Update()
    {
        RaycastHit hit;
        var mousePos = Input.mousePosition;
        _rayMouse = Cam.ScreenPointToRay(mousePos);
        if (Physics.Raycast(_rayMouse, out hit))
        {
            _hitUV = hit.textureCoord;
        }
        //如果鼠标左键持续按下
        if (Input.GetMouseButton(0))
        {
            CalTemperatureMat.SetVector(HitUV, _hitUV);
            Graphics.Blit(Rt1, Rt2, CalTemperatureMat, 0);
            Graphics.Blit(Rt2, Rt1);
        }
        else
        {
            Graphics.Blit(Rt1, Rt2, CalTemperatureMat, 1);
            Graphics.Blit(Rt2, Rt1);
        }
    }
}
