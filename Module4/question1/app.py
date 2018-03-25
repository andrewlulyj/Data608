# -*- coding: utf-8 -*-
import dash
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd 
import numpy as np
import datetime

url = "https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module4/Data/riverkeeper_data_2013.csv"
data = pd.read_csv(url)

data_list = np.unique(data['Date'])
data_list=sorted(data_list, key=lambda x: datetime.datetime.strptime(x, '%m/%d/%Y'))

for  i in range(0,len(data['EnteroCount'])):
    if ">" in data['EnteroCount'][i]:
        data['EnteroCount'][i] = int(data['EnteroCount'][i][1:])+1
    elif "<" in data['EnteroCount'][i]:
        data['EnteroCount'][i] = int(data['EnteroCount'][i][1:])-1
flag=['recommand' if int(i) < 110 else 'not recommand' for i in data['EnteroCount']]
data['flag'] = flag
data['EnteroCount'] = data['EnteroCount'].astype(int) 

app = dash.Dash()

app.layout = html.Div(children=[
    html.H1(children='Hello Dash'),

    html.Div(children='''
        Select A Date.
    '''),
    html.Div([
            dcc.Dropdown(
                id='d',
                options=[{'label': i, 'value': i} for i in data_list],
                value='9/26/2006'
               
            )]),
    dcc.Graph(
        id='graph'
    )
])

@app.callback(
    dash.dependencies.Output('graph', 'figure'),
    [dash.dependencies.Input('d', 'value')])
def update_graph(d_value):
    dd=[]
    filter_data=data[data['flag']=='recommand'] 
    filter_data=filter_data[filter_data['Date']==d_value]
    filter_data=filter_data.sort_values(by=['EnteroCount'])
    dd.append({'x': filter_data['Site'], 'y': filter_data['EnteroCount'], 'type': 'bar', 'name': 'SF'})
    return{
           'data':dd,
            'layout': {
                'title': 'Recommand Site ' + str(d_value),
                'yaxis': dict(title = 'Entero Count' )
            }
            }
if __name__ == '__main__':
    app.run_server(debug=False)