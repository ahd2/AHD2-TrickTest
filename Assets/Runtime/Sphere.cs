using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sphere : MonoBehaviour
{
    
    private Vector3 _originalPosition;
    void Start()
    {
        _originalPosition = transform.position;
        Debug.Log(_originalPosition);
    }

    void Update()
    {
        Vector3 impactDir = transform.position - LightSphere.SpherePosition;
        impactDir.y = 0f;
        float distance = Vector3.Distance(transform.position, LightSphere.SpherePosition);
        float imparctParam = Mathf.Clamp01(distance / SphereManager.MaxImpactDistance);//在自身到最大距离内，值从0变到1
        imparctParam = 1 - imparctParam;
        transform.position = _originalPosition +  impactDir.normalized * (SphereManager.MaxImpactIntensity * imparctParam);
    }
}
