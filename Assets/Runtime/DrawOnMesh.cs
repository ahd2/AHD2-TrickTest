using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOnMesh : MonoBehaviour
{
    public Camera Cam;
    private Ray RayMouse;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        RaycastHit hit; //DELATE THIS IF YOU WANT TO USE LASERS IN 2D
        var mousePos = Input.mousePosition;
        RayMouse = Cam.ScreenPointToRay(mousePos);
        if (Physics.Raycast(RayMouse, out hit))
        {
            Debug.Log(hit.point);
            Debug.Log(hit.textureCoord);
        }
    }
}
