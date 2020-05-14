import google
from django.http import HttpResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("ServiceAccountKey.json")
try:
    default_app = firebase_admin.initialize_app(cred)
except ValueError:
    default_app = firebase_admin.get_app()
db = firestore.client(default_app)



@api_view(["GET", "POST"])
def index(request):
    if request.method == "GET":
        try:
            docs = db.collection('images').stream()
            docs = [doc.to_dict() for doc in docs]
            return Response(docs)
        except google.cloud.exceptions.NotFound:
            return Response({"error": "Not Found"}, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == "POST":
        response = {
            'API_CALLED': True,
        }
        data = request.data
        doc_ref = db.collection('images').document('posted')
        doc_ref.set(data)
        return Response(data,status=status.HTTP_201_CREATED)
