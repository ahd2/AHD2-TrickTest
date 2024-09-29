using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOnMesh : MonoBehaviour
{
    public RenderTexture Rt1;
    public RenderTexture Rt2;
    public Camera Cam;
    private Ray _rayMouse;//相机指向鼠标点的射线
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit; //DELATE THIS IF YOU WANT TO USE LASERS IN 2D
        var mousePos = Input.mousePosition;
        _rayMouse = Cam.ScreenPointToRay(mousePos);
        if (Physics.Raycast(_rayMouse, out hit))
        {
            Debug.Log(hit.point);
            Debug.Log(hit.textureCoord);
        }
    }
}
