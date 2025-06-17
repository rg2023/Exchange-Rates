import React, { useState, useEffect, useMemo } from 'react';
import {
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  useReactTable,
} from '@tanstack/react-table';
import 'bootstrap/dist/css/bootstrap.min.css';



function ExchangeRateTable({ baseCurrency }) {
  // const backend_url = window.VITE_BACKEND_URL || "";
  const [exchangeRates, setExchangeRates] = useState([]);
  const [sorting, setSorting] = useState([]);

  useEffect(() => {
    async function fetchData() {
      try {
        const response = await fetch(`__BACKEND_URL__/exchange-rates/${baseCurrency}`);
        if (!response.ok) {
          throw new Error('Failed to fetch exchange rates');
        }
        const data = await response.json();
        setExchangeRates(data);
      } catch (error) {
        console.error('Error fetching exchange rates:', error);
      }
    }

    if (baseCurrency) {
      fetchData();
    }
  }, [baseCurrency]);

  const columns = useMemo(
    () => [
      {
        accessorKey: 'baseCurrency',
        header: 'Base Currency',
        enableSorting: false,
        cell: () => <p>{baseCurrency}</p>, 
      },
      {
        accessorKey: 'currency',
        header: 'Target Currency',
        enableSorting: true,
        cell: info => <p>{info.getValue()}</p>
      },
      {
        accessorKey: 'rate',
        header: 'Exchange Rate',
        enableSorting: true,
        cell: info => <p>{info.getValue().toFixed(2)}</p>
      }
    ],
    [baseCurrency] 
  );

  const table = useReactTable({
    data: exchangeRates,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });

  return (
    <div className="container mt-4">
      <table className="table table-striped table-bordered">
        <thead className="thead-dark">
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map(header => (
                <th key={header.id} colSpan={header.colSpan}>
                  {header.isPlaceholder ? null : (
                    <div
                      className={
                        header.column.getCanSort()
                          ? 'cursor-pointer select-none'
                          : ''
                      }
                      onClick={header.column.getToggleSortingHandler()}
                      title={
                        header.column.getCanSort()
                          ? header.column.getNextSortingOrder() === 'asc'
                            ? 'Sort ascending'
                            : header.column.getNextSortingOrder() === 'desc'
                              ? 'Sort descending'
                              : 'Clear sort'
                          : undefined
                      }
                    >
                      {flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                      {{
                        asc: ' 🔼',
                        desc: ' 🔽',
                      }[header.column.getIsSorted() ?? null]}
                    </div>
                  )}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id}>
                  {flexRender(
                    cell.column.columnDef.cell,
                    cell.getContext()
                  )}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default ExchangeRateTable;
