using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class LightSphere : MonoBehaviour
{
    private static readonly int Position = Shader.PropertyToID("_SpherePosition");
    //静态字段，全局只有一个。
    public static Vector3 SpherePosition { get; private set; }

    private void Start()
    {
    }

    private void Update()
    {
        SpherePosition = transform.position;
        Shader.SetGlobalVector(Position, SpherePosition);
    }
}
